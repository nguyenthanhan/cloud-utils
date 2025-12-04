#!/bin/bash

# ==============================================================================
#  RCLONE "STEALTH MODE" CONFIGURATION
# ==============================================================================

# 1. Fake User Agent: Pretend to be Chrome on Windows to avoid "Bot" detection.
USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

# 2. Optimization Flags (Using Bash Array to handle spaces correctly)
OPTS=(
    -P                              # Show progress
    --tpslimit 2                    # Limit HTTP transactions to 2 per second (Very slow to look human)
    --tpslimit-burst 2              # Prevent bursting requests
    --transfers 2                   # Low concurrency
    --checkers 2                    # Low file checking parallelism
    --drive-chunk-size 1024M         # Large chunk size for stability
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
#  MAIN LOOP
# ==============================================================================

for i in {1..100}; do
    echo "=========================================="
    echo " STARTING ROUND: $i"
    echo "=========================================="

    rclone copy od1:MAIN gd1:MAIN "${OPTS[@]}"

    rclone copy "od1:Torrent/Oversize" "gd4:Torrent/Oversize" "${OPTS[@]}"

    rclone copy "od1:Torrent/Private Photoshoot Bai Xue (Jia Fei)" "gd4:Torrent/Private Photoshoot Bai Xue (Jia Fei)" "${OPTS[@]}"

    rclone copy "od1:Torrent/Weekly Playboy 週刊プレイボーイ" "gd4:Torrent/Weekly Playboy 週刊プレイボーイ" "${OPTS[@]}"

    rclone copy "od1:Torrent/_reseed" "gd7:Torrent/_reseed" "${OPTS[@]}"

    # --- Sleep Logic ---
    echo "------------------------------------------"
    echo " ROUND $i COMPLETED."
    echo " SLEEPING FOR 5 MINUTES (300s) TO COOL DOWN API..."
    echo "------------------------------------------"
    sleep 300 
done