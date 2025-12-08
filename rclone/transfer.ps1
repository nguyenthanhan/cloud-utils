# ==============================================================================
#  RCLONE "STEALTH MODE" CONFIGURATION - Windows PowerShell Version
# ==============================================================================

# Set proxy environment variables if configured
if ($env:PROXY_URL) {
    $env:http_proxy = $env:PROXY_URL
    $env:https_proxy = $env:PROXY_URL
    $env:HTTP_PROXY = $env:PROXY_URL
    $env:HTTPS_PROXY = $env:PROXY_URL
    Write-Host "[PROXY] Proxy enabled: $env:PROXY_URL"
} else {
    Write-Host "[PROXY] No proxy configured (running without proxy)"
}

# 1. Fake User Agent: Pretend to be Chrome on Windows to avoid "Bot" detection.
$USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

# 2. Optimization Flags
$OPTS = @(
    "-P",                              # Show progress
    # "--tpslimit", "2",                 # Limit HTTP transactions to 2 per second (Very slow to look human)
    # "--tpslimit-burst", "2",           # Prevent bursting requests
    # "--transfers", "2",                # Low concurrency
    # "--checkers", "2",                 # Low file checking parallelism
    "--drive-chunk-size", "256M",     # Large chunk size for stability
    "--fast-list",                     # Use RAM to load file list (Reduces API calls significantly)
    "--drive-acknowledge-abuse",       # Bypass "virus/abuse" warnings on files
    # "--retries", "10",                 # Retry more often if connection drops
    # "--timeout", "100m",               # Long timeout for large files
    "-v",                              # Verbose logging (See what's happening during "Fast List")
    # "--bind", "0.0.0.0",               # CRITICAL: Force IPv4 usage (Google blocks IPv6 from VPS often)
    # "--user-agent", $USER_AGENT,       # Add User Agent
    # "--drive-pacer-min-sleep", "200ms" # Slow down API calls intentionally
)

# Optional: Bandwidth limit (Uncomment if you want to save the 750GB/day quota)
# $OPTS += "--bwlimit", "50M"

# ==============================================================================
#  HELPER FUNCTIONS
# ==============================================================================

# Function to check and display proxy status
function Check-ProxyStatus {
    Write-Host "------------------------------------------"
    Write-Host " PROXY STATUS CHECK"
    Write-Host "------------------------------------------"
    if ($env:PROXY_URL) {
        Write-Host "✓ Proxy is configured"
        Write-Host "  PROXY_URL: $env:PROXY_URL"
        Write-Host "  HTTP_PROXY: $(if ($env:HTTP_PROXY) { $env:HTTP_PROXY } else { 'not set' })"
        Write-Host "  HTTPS_PROXY: $(if ($env:HTTPS_PROXY) { $env:HTTPS_PROXY } else { 'not set' })"
        
        # Test if proxy is reachable
        Write-Host ""
        Write-Host "Testing proxy connectivity..."
        try {
            $response = Invoke-WebRequest -Uri "https://www.google.com" -Proxy $env:PROXY_URL -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
            Write-Host "✓ Proxy is reachable"
        } catch {
            Write-Host "✗ Warning: Proxy may not be reachable"
        }
    } else {
        Write-Host "✗ No proxy configured"
        Write-Host "  Running without proxy"
    }
    Write-Host "------------------------------------------"
    Write-Host ""
}

function Copy-Rclone {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path,
        [Parameter(Mandatory=$true)]
        [string]$Source,
        [Parameter(Mandatory=$true)]
        [string]$Destination
    )
    
    # Source must be "remote:" or "remote:path_prefix/" format - just concatenate
    $sourceFull = "${Source}${Path}"
    
    # Destination: if starts with G:\ or /, it's local path, otherwise it's remote format
    $destFull = if ($Destination -match "^[A-Z]:\\" -or $Destination -match "^/") {
        "$Destination\$Path"
    } else {
        "${Destination}${Path}"
    }
    
    # Set proxy if configured
    $cmd = @("rclone", "copy", $sourceFull, $destFull)
    if ($env:PROXY_URL) {
        $env:http_proxy = $env:PROXY_URL
        $env:https_proxy = $env:PROXY_URL
        $env:HTTP_PROXY = $env:PROXY_URL
        $env:HTTPS_PROXY = $env:PROXY_URL
    }
    $cmd += $OPTS
    
    Write-Host "Copying: $sourceFull -> $destFull"
    & $cmd[0] @($cmd[1..($cmd.Length-1)])
}

# ==============================================================================
#  MAIN EXECUTION FUNCTION
# ==============================================================================

function Start-Transfer {
    Write-Host "=========================================="
    Write-Host " STARTING RCLONE TRANSFER"
    Write-Host "=========================================="
    
    # Display proxy status
    Check-ProxyStatus

    # Source must be "remote:" or "remote:path_prefix/" format
    # Destination can be "remote:" or "remote:path_prefix/" for remote, or local path (G:\ or /) for local
    # Copy to local Windows

    # od0:
    Copy-Rclone -Path "23.10.21.gd/Daisy Taylor Pack" -Source "od0:Torrent0/" -Destination "G:\Transfer"

    # od1:
    Copy-Rclone -Path "Torrent/Oversize" -Source "od1:" -Destination "gd4:"
    Copy-Rclone -Path "Torrent/_reseed" -Source "od1:" -Destination "gd7:"

    # od3:
    Copy-Rclone -Path "Torrent3/_like8/Onlyfans - Hanson Hookup God, Big And Fierce, Explosively Fucks" -Source "od3:" -Destination "G:\Transfer"

    Write-Host "------------------------------------------"
    Write-Host " TRANSFER COMPLETED."
    Write-Host "------------------------------------------"
}

# Execute transfer
Start-Transfer
