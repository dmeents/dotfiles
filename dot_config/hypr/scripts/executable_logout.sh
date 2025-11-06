#!/bin/bash

# Find and kill Electron applications that may prevent logout
find_electron_apps() {
    local electron_pids=()
    
    # Find processes with electron in their command line or that have resources/app.asar
    while IFS= read -r pid; do
        # Check if process exe path contains electron or has electron resources
        local exe_path=$(readlink -f "/proc/$pid/exe" 2>/dev/null || echo "")
        local cwd_path=$(readlink -f "/proc/$pid/cwd" 2>/dev/null || echo "")
        
        if [[ -n "$exe_path" ]] && (
            [[ "$exe_path" == *electron* ]] || 
            [[ -d "${exe_path%/*}/../resources" ]] || 
            [[ -d "$cwd_path/resources" ]]
        ); then
            electron_pids+=("$pid")
        fi
    done < <(pgrep -x ".*" 2>/dev/null || ps -eo pid --no-headers)
    
    echo "${electron_pids[@]}"
}

# Gracefully terminate Electron apps
echo "Finding Electron applications..."
electron_pids=($(find_electron_apps))

if [[ ${#electron_pids[@]} -gt 0 ]]; then
    echo "Terminating ${#electron_pids[@]} Electron app(s)..."
    for pid in "${electron_pids[@]}"; do
        kill -TERM "$pid" 2>/dev/null
    done
    
    # Give apps 2 seconds to close gracefully
    sleep 2
    
    # Force kill if still running
    for pid in "${electron_pids[@]}"; do
        if kill -0 "$pid" 2>/dev/null; then
            echo "Force killing PID $pid..."
            kill -KILL "$pid" 2>/dev/null
        fi
    done
else
    echo "No Electron apps found."
fi

# Exit Hyprland
hyprctl dispatch exit
