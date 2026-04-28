# Function to list all sync configurations
list_all_configs() {
    local check_status="${1:-false}"  # Default to false (no status check)
    
    # Load secrets first to ensure configuration arrays are available
    load_secrets
    
    local pg_sources_connected=0
    local pg_sources_disconnected=0
    local pg_targets_connected=0
    local pg_targets_disconnected=0
    local mongo_sources_connected=0
    local mongo_sources_disconnected=0
    local mongo_targets_connected=0
    local mongo_targets_disconnected=0
    
    echo ""
    echo "🐘 PostgreSQL Sources (${#POSTGRES_SOURCES[@]}):"
    if [[ ${#POSTGRES_SOURCES[@]} -gt 0 ]]; then
        local i=1
        for source in "${POSTGRES_SOURCES[@]}"; do
            IFS='|' read -r name url database <<< "$source"
            local host=$(extract_postgres_host "$url")
            
            # Test connection if check_status is enabled
            local status_icon=""
            if [[ "$check_status" == "true" ]]; then
                if test_postgres_connection "$url" "$name" "true" >/dev/null 2>&1; then
                    status_icon="🟢 "
                    ((pg_sources_connected++))
                else
                    status_icon="🔴 "
                    ((pg_sources_disconnected++))
                fi
            fi
            
            echo "  ${status_icon}${i}) ${name} → ${database} | ${host}"
            i=$((i + 1))
        done
    else
        echo "  (No PostgreSQL sources configured)"
    fi
    
    echo ""
    echo "🎯 PostgreSQL Targets (${#POSTGRES_TARGETS[@]}):"
    if [[ ${#POSTGRES_TARGETS[@]} -gt 0 ]]; then
        local i=1
        for target in "${POSTGRES_TARGETS[@]}"; do
            IFS='|' read -r name url <<< "$target"
            local host=$(extract_postgres_host "$url")
            # Extract sslmode from URL for display
            local ssl_display="disable"
            if echo "$url" | grep -q "sslmode=require"; then
                ssl_display="require"
            fi
            
            # Test connection if check_status is enabled
            local status_icon=""
            if [[ "$check_status" == "true" ]]; then
                if test_postgres_connection "$url" "$name" "true" >/dev/null 2>&1; then
                    status_icon="🟢 "
                    ((pg_targets_connected++))
                else
                    status_icon="🔴 "
                    ((pg_targets_disconnected++))
                fi
            fi
            
            echo "  ${status_icon}${i}) ${name} | ${host} [SSL: ${ssl_display}]"
            i=$((i + 1))
        done
    else
        echo "  (No PostgreSQL targets configured)"
    fi
    
    echo ""
    echo "🍃 MongoDB Sources (${#MONGO_SOURCES[@]}):"
    if [[ ${#MONGO_SOURCES[@]} -gt 0 ]]; then
        local i=1
        for source in "${MONGO_SOURCES[@]}"; do
            IFS='|' read -r name uri databases <<< "$source"
            local host=$(extract_mongo_host "$uri")
            
            # Test connection if check_status is enabled
            local status_icon=""
            if [[ "$check_status" == "true" ]]; then
                if test_mongo_connection "${uri}" "${name}" "true" >/dev/null 2>&1; then
                    status_icon="🟢 "
                    ((mongo_sources_connected++))
                else
                    status_icon="🔴 "
                    ((mongo_sources_disconnected++))
                fi
            fi
            
            echo "  ${status_icon}${i}) ${name} → ${databases} | ${host}"
            i=$((i + 1))
        done
    else
        echo "  (No MongoDB sources configured)"
    fi
    
    echo ""
    echo "🎯 MongoDB Targets (${#MONGO_TARGETS[@]}):"
    if [[ ${#MONGO_TARGETS[@]} -gt 0 ]]; then
        local i=1
        for target in "${MONGO_TARGETS[@]}"; do
            IFS='|' read -r name uri <<< "$target"
            local host=$(extract_mongo_host "$uri")
            
            # Test connection if check_status is enabled
            local status_icon=""
            if [[ "$check_status" == "true" ]]; then
                if test_mongo_connection "${uri}" "${name}" "true" >/dev/null 2>&1; then
                    status_icon="🟢 "
                    ((mongo_targets_connected++))
                else
                    status_icon="🔴 "
                    ((mongo_targets_disconnected++))
                fi
            fi
            
            echo "  ${status_icon}${i}) ${name} | ${host}"
            i=$((i + 1))
        done
    else
        echo "  (No MongoDB targets configured)"
    fi
    
    # Display summary only if check_status is enabled
    if [[ "$check_status" == "true" ]]; then
        if [[ ${#POSTGRES_SOURCES[@]} -gt 0 ]] || [[ ${#POSTGRES_TARGETS[@]} -gt 0 ]] || \
           [[ ${#MONGO_SOURCES[@]} -gt 0 ]] || [[ ${#MONGO_TARGETS[@]} -gt 0 ]]; then
            # Calculate totals
            local total_connected=$((pg_sources_connected + pg_targets_connected + mongo_sources_connected + mongo_targets_connected))
            local total_disconnected=$((pg_sources_disconnected + pg_targets_disconnected + mongo_sources_disconnected + mongo_targets_disconnected))
            
            echo ""
            echo "Summary: 🟢 ${total_connected} connected  |  🔴 ${total_disconnected} disconnected"
        fi
    fi
    
    echo ""
}
