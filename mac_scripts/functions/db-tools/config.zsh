# =============================================================================
# Database Tool - Unified Database Connection & Sync Manager
# =============================================================================

# Global variables
typeset -g SSH_TIMEOUT=10
typeset -g DBT_SECRETS_LOADED="false"
typeset -g DBT_SECRETS_FILE=""
typeset -g DBT_SECRETS_MTIME=""

# Find secrets file - prioritize source code root, fallback to iCloud
find_secrets_file() {
    # Try to find root of source code (where dbt_secrets.example is located)
    # Start from script directory and go up to find the root
    local current_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
    local root_dir=""
    
    # Look for dbt_secrets.example to identify root
    while [[ "$current_dir" != "/" ]]; do
        if [[ -f "$current_dir/dbt_secrets.example" ]]; then
            root_dir="$current_dir"
            break
        fi
        current_dir="$(dirname "$current_dir")"
    done
    
    # First priority: source code root
    if [[ -n "$root_dir" ]] && [[ -f "$root_dir/dbt_secrets" ]]; then
        echo "$root_dir/dbt_secrets"
        return 0
    fi
    
    # Second priority: iCloud Drive
    local icloud_drive_root="${HOME}/Library/Mobile Documents/com~apple~CloudDocs"
    local icloud_secrets="${icloud_drive_root}/Backups/dbt_secrets"
    if [[ -f "$icloud_secrets" ]]; then
        echo "$icloud_secrets"
        return 0
    fi
    
    # Not found
    return 1
}

# Auto-load VPS configurations from secrets file
# This ensures we always use the latest configurations
{
    local secrets_file
    if secrets_file=$(find_secrets_file 2>/dev/null); then
        # Source secrets file and suppress all output (including debug output)
        {
            source "$secrets_file" 2>/dev/null
        } >/dev/null 2>&1
        
        if [[ -z "${VPS_CONFIGS[@]}" ]]; then
            echo "⚠️  Warning: VPS_CONFIGS not found in secrets file"
            echo "   Please define VPS_CONFIGS array in $secrets_file"
            typeset -a VPS_CONFIGS=()
        fi
    else
        echo "⚠️  Warning: Secrets file not found"
        echo "   Please create dbt_secrets in source root or iCloud Drive"
        typeset -a VPS_CONFIGS=()
    fi
}

# =============================================================================
# Shared Utility Functions
# =============================================================================

# Get file modification time (epoch seconds)
_get_file_mtime() {
    local file_path="$1"
    stat -f "%m" "$file_path" 2>/dev/null
}

# Load secrets from secrets file
load_secrets() {
    local secrets_file
    if ! secrets_file=$(find_secrets_file 2>/dev/null); then
        echo "⚠️  Warning: Secrets file not found"
        echo "   Please create dbt_secrets in source root or iCloud Drive"
        export VPS_CONFIGS=()
        export POSTGRES_SOURCES=()
        export POSTGRES_TARGETS=()
        export MONGO_SOURCES=()
        export MONGO_TARGETS=()
        DBT_SECRETS_LOADED="false"
        DBT_SECRETS_FILE=""
        DBT_SECRETS_MTIME=""
        return 1
    fi

    local secrets_mtime
    secrets_mtime=$(_get_file_mtime "$secrets_file")
    if [[ "$DBT_SECRETS_LOADED" == "true" ]] && \
       [[ "$DBT_SECRETS_FILE" == "$secrets_file" ]] && \
       [[ -n "$secrets_mtime" ]] && \
       [[ "$DBT_SECRETS_MTIME" == "$secrets_mtime" ]]; then
        return 0
    fi
    
    # Source secrets file - suppress all output like db_connection_tool does
    {
        source "$secrets_file" 2>/dev/null
    } >/dev/null 2>&1
    
    # Export arrays as global variables to ensure they're available outside this function
    if [[ -n "${VPS_CONFIGS[@]}" ]]; then
        export VPS_CONFIGS=("${VPS_CONFIGS[@]}")
    else
        export VPS_CONFIGS=()
    fi
    
    if [[ -n "${POSTGRES_SOURCES[@]}" ]]; then
        export POSTGRES_SOURCES=("${POSTGRES_SOURCES[@]}")
    else
        export POSTGRES_SOURCES=()
    fi
    
    if [[ -n "${POSTGRES_TARGETS[@]}" ]]; then
        export POSTGRES_TARGETS=("${POSTGRES_TARGETS[@]}")
    else
        export POSTGRES_TARGETS=()
    fi
    
    if [[ -n "${MONGO_SOURCES[@]}" ]]; then
        export MONGO_SOURCES=("${MONGO_SOURCES[@]}")
    else
        export MONGO_SOURCES=()
    fi
    
    if [[ -n "${MONGO_TARGETS[@]}" ]]; then
        export MONGO_TARGETS=("${MONGO_TARGETS[@]}")
    else
        export MONGO_TARGETS=()
    fi
    
    # Warn if no configs found
    if [[ ${#VPS_CONFIGS[@]} -eq 0 ]] && [[ ${#POSTGRES_SOURCES[@]} -eq 0 ]] && [[ ${#MONGO_SOURCES[@]} -eq 0 ]]; then
        echo "⚠️  Warning: No configurations found in secrets file"
        echo "   Please define VPS_CONFIGS, POSTGRES_SOURCES, and/or MONGO_SOURCES in $secrets_file"
    fi

    DBT_SECRETS_LOADED="true"
    DBT_SECRETS_FILE="$secrets_file"
    DBT_SECRETS_MTIME="$secrets_mtime"
}

# Log message to stdout
log() {
    local level=$1
    shift
    local message="$@"
    
    if [[ "$level" == "ERROR" ]]; then
        echo "❌ $message" >&2
    elif [[ "$level" == "WARN" ]]; then
        echo "⚠️  $message"
    elif [[ "$level" == "INFO" ]]; then
        echo "ℹ️  $message"
    fi
}
