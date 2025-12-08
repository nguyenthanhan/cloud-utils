#!/bin/bash

# ==============================================================================
#  RCLONE "STEALTH MODE" CONFIGURATION
# ==============================================================================

# Set proxy environment variables if configured
if [ -n "$PROXY_URL" ]; then
    export http_proxy="$PROXY_URL"
    export https_proxy=$http_proxy
    export HTTP_PROXY=$http_proxy
    export HTTPS_PROXY=$http_proxy
    echo "[PROXY] Proxy enabled: $PROXY_URL"
else
    echo "[PROXY] No proxy configured (running without proxy)"
fi

# 1. Fake User Agent: Pretend to be Chrome on Windows to avoid "Bot" detection.
USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

# 2. Optimization Flags (Using Bash Array to handle spaces correctly)
OPTS=(
    -P                              # Show progress
    --tpslimit 2                    # Limit HTTP transactions to 2 per second (Very slow to look human)
    --tpslimit-burst 2              # Prevent bursting requests
    --transfers 2                   # Low concurrency
    --checkers 2                    # Low file checking parallelism
    --drive-chunk-size 256M         # Large chunk size for stability
    --fast-list                     # Use RAM to load file list (Reduces API calls significantly)
    --drive-acknowledge-abuse       # Bypass "virus/abuse" warnings on files
    --retries 10                    # Retry more often if connection drops
    --timeout 100m                   # Long timeout for large files
    -v                              # Verbose logging (See what's happening during "Fast List")
    --bind 0.0.0.0                  # CRITICAL: Force IPv4 usage (Google blocks IPv6 from VPS often)
)

# Add User Agent to the options
OPTS+=(--user-agent "$USER_AGENT")

# Add Pacer (Slow down API calls intentionally). Remove this line if your rclone version is old.
OPTS+=(--drive-pacer-min-sleep 200ms)

# Optional: Bandwidth limit (Uncomment if you want to save the 750GB/day quota)
OPTS+=(--bwlimit 50M)

# ==============================================================================
#  HELPER FUNCTIONS
# ==============================================================================

# Function to check and display proxy status
check_proxy_status() {
    echo "------------------------------------------"
    echo " PROXY STATUS CHECK"
    echo "------------------------------------------"
    if [ -n "$PROXY_URL" ]; then
        echo "✓ Proxy is configured"
        echo "  PROXY_URL: $PROXY_URL"
        echo "  HTTP_PROXY: ${HTTP_PROXY:-not set}"
        echo "  HTTPS_PROXY: ${HTTPS_PROXY:-not set}"
        
        # Test if proxy is reachable
        echo ""
        echo "Testing proxy connectivity..."
        if curl -s --proxy "$PROXY_URL" --max-time 5 https://www.google.com > /dev/null 2>&1; then
            echo "✓ Proxy is reachable"
        else
            echo "✗ Warning: Proxy may not be reachable"
        fi
    else
        echo "✗ No proxy configured"
        echo "  Running without proxy"
    fi
    echo "------------------------------------------"
    echo ""
}

copy_rclone() {
    local path="$1"
    local source="$2"
    local destination="$3"
    
    # Source must be "remote:" or "remote:path_prefix/" format - just concatenate
    local source_full="${source}${path}"
    
    # Destination: if starts with /, it's local path, otherwise it's remote format
    local dest_full
    if [[ "$destination" == /* ]]; then
        dest_full="${destination}/${path}"
    else
        dest_full="${destination}${path}"
    fi
    
    echo "Copying: $source_full -> $dest_full"
    rclone copy "$source_full" "$dest_full" "${OPTS[@]}"
}

# ==============================================================================
#  MAIN EXECUTION FUNCTION
# ==============================================================================

start_transfer() {
    echo "=========================================="
    echo " STARTING RCLONE TRANSFER"
    echo "=========================================="
    
    # Display proxy status
    check_proxy_status

    # Source must be "remote:" or "remote:path_prefix/" format
    # Destination can be "remote:" or "remote:path_prefix/" for remote, or local path (starts with /) for local
    # Copy to local Mac/Linux

    copy_rclone "Torrent/Oversize" "od1:" "gd4:"

    echo "------------------------------------------"
    echo " TRANSFER COMPLETED."
    echo "------------------------------------------"
}

# Execute transfer
start_transfer