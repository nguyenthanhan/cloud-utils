#!/bin/bash

# Generate random 32 hex characters (16 bytes) for MTProto secrets
mtg_secret=$(head -c 16 /dev/urandom | xxd -p)
telegram_secret=$(head -c 16 /dev/urandom | xxd -p)

# Get current timestamp (format: YYYY-MM-DD HH:MM:SS)
timestamp=$(date '+%Y-%m-%d %H:%M:%S')

# Path to local .env file
ENV_FILE=".env"

# Function to update or add environment variable
update_env_var() {
    local var_name=$1
    local var_value=$2
    local env_file=$3
    
    if [ -f "$env_file" ] && grep -q "^${var_name}=" "$env_file"; then
        # Variable exists, update it
        sed -i "s/^${var_name}=.*/${var_name}=${var_value}/" "$env_file"
        echo "Updated $var_name in $env_file"
    else
        # Variable doesn't exist, add it
        echo "${var_name}=${var_value}" >> "$env_file"
        echo "Added $var_name to $env_file"
    fi
}

# Create .env file if it doesn't exist
if [ ! -f "$ENV_FILE" ]; then
    echo "# MTProto Proxy Configuration" > "$ENV_FILE"
    echo "# Generated on: $timestamp" >> "$ENV_FILE"
    echo "" >> "$ENV_FILE"
    echo "Created new $ENV_FILE file"
fi

# Update or add the secrets
update_env_var "MTPROTO_MTG_SECRET" "$mtg_secret" "$ENV_FILE"
update_env_var "MTPROTO_TELEGRAM_SECRET" "$telegram_secret" "$ENV_FILE"

echo ""
echo "Generated new MTProto secrets:"
echo "MTG Secret: $mtg_secret"
echo "Telegram Secret: $telegram_secret" 
echo "Timestamp: $timestamp"
echo ""
echo "Secrets saved to $ENV_FILE"
