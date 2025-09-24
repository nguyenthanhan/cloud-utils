# Generate random 16 bytes  ^f^r 32 hex characters
random_hex=$(head -c 16 /dev/urandom | xxd -p)

# Get current timestamp (format: YYYY-MM-DD HH:MM:SS)
timestamp=$(date '+%Y-%m-%d %H:%M:%S')

# Update SECRET in docker-compose.yml
sed -i "s/SECRET=.*/SECRET=$random_hex/" docker-compose.yml

echo "Updated docker-compose.yml SECRET to: $random_hex"
echo "Saved: [$timestamp] $random_hex"
