#!/bin/bash
# Stand up a lean single-node k3s cluster on this workstation to host GitHub
# Actions self-hosted runners via Actions Runner Controller (ARC). The ARC
# install itself (CRDs, controller, runner scale sets) is NOT managed here --
# it's applied into the cluster separately (helm/kubectl); this script only
# owns the k3s substrate: config + service + local kubeconfig.
#
# Why k3s (and not the old Docker-Desktop runner setup it replaces): k3s runs
# as a system-level systemd service on its own bundled containerd, so it
# survives logout and doesn't churn under load the way the session-bound
# Docker-Desktop pool did. It coexists with Docker Desktop (whose engine lives
# in a VM), so the two don't fight over the host's containerd/iptables.
#
# The k3s binary + kubectl/crictl come from the `k3s-bin` AUR package (in the
# manifest, installed by run_onchange_after_install-packages_linux.sh, which
# sorts before this script). The config lives under /etc (root-owned), so this
# needs sudo -- run `chezmoi apply` in an interactive shell (same as the package
# installer). Idempotent; run_onchange => re-runs only when the text below
# (including the embedded config) changes, at which point it restarts k3s so the
# new config takes effect.
set -uo pipefail

CONFIG_PATH="/etc/rancher/k3s/config.yaml"
KUBECONFIG_SRC="/etc/rancher/k3s/k3s.yaml"
USER_KUBECONFIG="$HOME/.kube/config"

# k3s-bin should already be installed by the package step. If the AUR build
# failed, don't crash the whole apply -- warn and let the next apply retry.
if ! command -v k3s >/dev/null 2>&1; then
    echo "==> k3s not installed yet (k3s-bin build may have failed); skipping setup" >&2
    exit 0
fi

# --- Client symlinks --------------------------------------------------------
# The k3s-bin AUR package ships only /usr/bin/k3s (unlike the upstream installer,
# which drops kubectl/crictl/ctr symlinks). k3s is a multi-call binary, so
# symlink the client names to it -- ARC/helm workflows expect a real `kubectl`.
# /usr/local/bin isn't owned by pacman, so these won't collide with the package.
K3S_BIN="$(command -v k3s)"
for name in kubectl crictl ctr; do
    if [ ! -e "/usr/local/bin/$name" ]; then
        echo "==> Linking /usr/local/bin/$name -> $K3S_BIN (needs sudo)"
        sudo ln -sf "$K3S_BIN" "/usr/local/bin/$name"
    fi
done

# --- Lean k3s config for ARC ------------------------------------------------
# Disable Traefik (ARC's listener model needs no ingress) and ServiceLB (no
# LoadBalancer services), and make the kubeconfig readable by this user so
# kubectl works without sudo on this single-user box. Re-enable either disable
# if you later expose services via ingress / need a LoadBalancer.
read -r -d '' K3S_CONFIG <<'EOF'
# Managed by chezmoi (run_onchange_after_setup-k3s.sh) -- edit there, not here.
# Lean single-node cluster for GitHub Actions runners (ARC).
disable:
  - traefik
  - servicelb
write-kubeconfig-mode: "0644"
EOF

echo "==> Installing $CONFIG_PATH (needs sudo)"
sudo mkdir -p "$(dirname "$CONFIG_PATH")"
printf '%s\n' "$K3S_CONFIG" | sudo tee "$CONFIG_PATH" >/dev/null

# --- Enable + (re)start the service ----------------------------------------
# First run: enable --now starts it with the config above. Later runs (this
# script changed): restart so the new config is picked up.
if systemctl is-active --quiet k3s.service; then
    echo "==> k3s already running; restarting to apply config"
    sudo systemctl restart k3s.service
else
    echo "==> Enabling + starting k3s.service"
    sudo systemctl enable --now k3s.service
fi

# --- Wait for the API to come up + kubeconfig to be written ----------------
echo "==> Waiting for the k3s API to become ready"
ready=0
for _ in $(seq 1 45); do
    if sudo k3s kubectl get --raw='/readyz' >/dev/null 2>&1; then ready=1; break; fi
    sleep 2
done
if [ "$ready" -ne 1 ]; then
    echo "==> k3s API not ready after ~90s; check: journalctl -u k3s -e" >&2
    exit 1
fi

# --- Wire up the user's kubeconfig -----------------------------------------
# k3s writes /etc/rancher/k3s/k3s.yaml (0644 per config above). Point kubectl
# at it for this user + the ARC agent. Don't clobber an existing ~/.kube/config
# (it may merge other clusters) -- just tell the user how to use it.
if [ -r "$KUBECONFIG_SRC" ]; then
    if [ ! -e "$USER_KUBECONFIG" ]; then
        mkdir -p "$(dirname "$USER_KUBECONFIG")"
        install -m 600 "$KUBECONFIG_SRC" "$USER_KUBECONFIG"
        echo "==> Wrote $USER_KUBECONFIG (kubectl works out of the box)"
    else
        echo "==> $USER_KUBECONFIG already exists; not overwriting."
        echo "    Use k3s directly with: export KUBECONFIG=$KUBECONFIG_SRC"
        echo "    or merge it into your config with: KUBECONFIG=~/.kube/config:$KUBECONFIG_SRC kubectl config view --flatten"
    fi
fi

# --- In-cluster GUI: Headlamp ----------------------------------------------
# Lightweight web dashboard (CNCF / kubernetes-sigs), installed via helm. Chosen
# over Rancher because Rancher caps at k8s 1.35 (this cluster is newer) and would
# drag in cert-manager + an ingress controller; Headlamp needs none of that.
# No ingress: reach it via `kubectl port-forward` and log in with a non-expiring
# service-account token (the Secret below). Runs as this user (no sudo); KUBECONFIG is pinned to the
# k3s file so it always targets THIS cluster regardless of ~/.kube/config.
if command -v helm >/dev/null 2>&1; then
    export KUBECONFIG="$KUBECONFIG_SRC"
    echo "==> Installing/upgrading Headlamp (helm)"
    helm repo add headlamp https://kubernetes-sigs.github.io/headlamp/ >/dev/null 2>&1 || true
    helm repo update headlamp >/dev/null 2>&1 || true
    if helm upgrade --install headlamp headlamp/headlamp \
        --namespace headlamp --create-namespace --wait --timeout 3m >/dev/null 2>&1; then
        # Admin service account for token login (idempotent).
        kubectl apply -f - >/dev/null 2>&1 <<'YAML'
apiVersion: v1
kind: ServiceAccount
metadata:
  name: headlamp-admin
  namespace: headlamp
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: headlamp-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: headlamp-admin
    namespace: headlamp
---
# Non-expiring login token. `kubectl create token` mints short-lived (~1h,
# cluster-capped lower) tokens via the TokenRequest API, which meant re-minting
# every ~30min. A Secret of this type makes the token controller populate a
# JWT that stays valid as long as this Secret + its ServiceAccount exist.
apiVersion: v1
kind: Secret
metadata:
  name: headlamp-admin-token
  namespace: headlamp
  annotations:
    kubernetes.io/service-account.name: headlamp-admin
type: kubernetes.io/service-account-token
YAML
        echo "==> Headlamp ready. Reach the dashboard with:"
        echo "      kubectl -n headlamp port-forward svc/headlamp 8080:80"
        echo "    then open http://localhost:8080 and paste the non-expiring token from:"
        echo "      kubectl -n headlamp get secret headlamp-admin-token -o jsonpath='{.data.token}' | base64 -d"
    else
        echo "==> Headlamp helm install failed; check: helm -n headlamp status headlamp" >&2
    fi
else
    echo "==> helm not found; skipping Headlamp (ensure 'helm' is in the manifest)" >&2
fi

echo "==> k3s ready."
echo "    Verify: kubectl get nodes            # expect one Ready node"
