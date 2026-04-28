sync_dots_start() {
    local message="$1"
    local pid_var_name="$2"
    
    (
        local frames=('.  ' '.. ' '...')
        local idx=1
        local count=${#frames[@]}
        # Hide cursor to prevent flickering
        printf '\033[?25l'
        while true; do
            printf "\r%s%s" "$message" "${frames[$idx]}"
            idx=$(( idx % count + 1 ))
            sleep 0.5
        done
    ) &
    
    eval "${pid_var_name}=$!"
}

sync_dots_stop() {
    local spinner_pid="$1"
    
    if [[ -n "$spinner_pid" ]]; then
        kill "$spinner_pid" >/dev/null 2>&1 || true
        wait "$spinner_pid" >/dev/null 2>&1 || true
        # Show cursor again and clear the line
        printf '\033[?25h\r'
    fi
}
