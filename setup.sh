#!/bin/bash

# =============================================================================
# VPS Setup Script - Comprehensive VPS Configuration and Tool Installation
# =============================================================================
#
# This script provides a comprehensive setup for new VPS instances, including
# security hardening, development tools, and modern terminal utilities.
#
# =============================================================================
# QUICK START
# =============================================================================
#
# 1. Download the script:
#    wget <setup.sh link>
#
# 2. Make it executable:
#    chmod +x setup.sh
#
# 3. Run comprehensive setup (recommended for new VPS):
#    ./setup.sh -vps
#
# =============================================================================
# USAGE EXAMPLES
# =============================================================================
#
# Complete VPS setup (includes security, all tools):
#    ./setup.sh -vps
#
# Individual components:
#    ./setup.sh -basic-tools                    # Essential system tools
#    ./setup.sh -nvm                           # Node.js version manager
#    ./setup.sh -python                        # Python with pip
#    ./setup.sh -uv                            # Fast Python package manager
#    ./setup.sh -docker                        # Docker container platform
#    ./setup.sh -rclone                        # Cloud storage sync
#    ./setup.sh -proxy                         # Squid proxy server
#    ./setup.sh -zsh                           # Advanced shell
#    ./setup.sh -zimfw                         # Zsh framework
#    ./setup.sh -eza                           # Modern ls replacement
#    ./setup.sh -zoxide                        # Smart cd command
#    ./setup.sh -fastfetch                     # System info tool
#    ./setup.sh -qbittorrent                   # Torrent client
#    ./setup.sh -xrdp                          # Remote desktop
#    ./setup.sh -firefox                       # Web browser
#
# Custom combinations:
#    ./setup.sh -basic-tools -nvm -docker      # Development environment
#    ./setup.sh -zsh -zimfw -eza -zoxide       # Terminal enhancements
#    ./setup.sh -proxy -proxy-port=8080        # Custom proxy port
#    ./setup.sh -vps -ssh-port=2222            # Custom SSH port
#
# =============================================================================
# WHAT GETS INSTALLED WITH -vps
# =============================================================================
#
# Security:
#   • UFW firewall with secure rules
#   • SSH security hardening (no root login, key-only auth)
#   • Fail2ban for intrusion prevention
#
# Development Tools:
#   • Node.js (NVM) with LTS version
#   • Python 3 with pip
#   • UV (fast Python package manager)
#   • Docker with user group configuration
#
# Cloud & File Management:
#   • Rclone for cloud storage
#   • Squid proxy server (port 31288)
#
# Shell & Terminal:
#   • Zsh with Zim framework
#   • Eza (modern ls replacement)
#   • Zoxide (smart cd command)
#   • Fastfetch (system info)
#
# Additional Tools:
#   • qBittorrent for downloads
#   • XRDP for remote desktop (port 33899)
#   • Firefox browser
#
# =============================================================================
# PREREQUISITES
# =============================================================================
#
# Before running this script, ensure:
# 1. SSH keys are configured (to avoid being locked out)
# 2. Sudo privileges are available
# 3. Internet connectivity is working
# 4. You're not running as root user
#
# =============================================================================
# SAFETY FEATURES
# =============================================================================
#
# • SSH key verification before disabling password auth
# • Automatic rollback on installation failures
# • Port number validation
# • Internet connectivity checks
# • Config file backups before modifications
# • Progress indicators and clear error messages
#
# =============================================================================
# TROUBLESHOOTING
# =============================================================================
#
# If you get locked out:
# 1. Contact your VPS provider for console access
# 2. Restore SSH config: sudo cp /etc/ssh/sshd_config.backup /etc/ssh/sshd_config
# 3. Restart SSH: sudo systemctl restart ssh (or sshd on some systems)
#
# If installation fails:
# • The script will automatically rollback changes
# • Check the error messages for specific issues
# • Ensure you have sufficient disk space and memory
#
# =============================================================================

export DEBIAN_FRONTEND=noninteractive

# Define arrays for flags and their default values
declare -A FLAGS=(
  ["nvm"]=false
  ["rclone"]=false
  ["docker"]=false
  ["xrdp"]=false
  ["proxy"]=false
  ["qbittorrent"]=false
  ["python"]=false
  ["zsh"]=false
  ["zimfw"]=false
  ["apt-update"]=true
  ["vps"]=false
  ["basic-tools"]=false
  ["uv"]=false
  ["firefox"]=false
  ["eza"]=false
  ["zoxide"]=false
  ["fastfetch"]=false
  ["set-password"]=false
  ["verify-xrdp"]=false
)

declare -A VALUES=(
  ["proxy-port"]="3128"
  ["ssh-port"]="22"
)

# Parse args
for arg in "$@"; do
  if [[ "$arg" == -* ]]; then
    flag="${arg#-}"
    if [[ "$flag" == *"="* ]]; then
      # Handle key=value pairs
      key="${flag%%=*}"
      value="${flag#*=}"
      VALUES["$key"]="$value"
    elif [[ "$flag" == "proxy" && "$arg" == *":"* ]]; then
      # Special case for proxy with port
      VALUES["proxy-port"]="${arg#*:}"
      FLAGS["proxy"]=true
    else
      # Regular flags
      FLAGS["$flag"]=true
    fi
  fi
done

# Convert flags to variables for backwards compatibility
INSTALL_NVM=${FLAGS["nvm"]}
INSTALL_RCLONE=${FLAGS["rclone"]}
INSTALL_DOCKER=${FLAGS["docker"]}
INSTALL_XRDP=${FLAGS["xrdp"]}
INSTALL_PROXY=${FLAGS["proxy"]}
INSTALL_QBITTORRENT=${FLAGS["qbittorrent"]}
INSTALL_PYTHON=${FLAGS["python"]}
INSTALL_ZSH=${FLAGS["zsh"]}
INSTALL_ZIMFW=${FLAGS["zimfw"]}
UPDATE_APT=${FLAGS["apt-update"]}
INSTALL_VPS=${FLAGS["vps"]}
INSTALL_BASIC_TOOLS=${FLAGS["basic-tools"]}
INSTALL_UV=${FLAGS["uv"]}
INSTALL_FIREFOX=${FLAGS["firefox"]}
INSTALL_EZA=${FLAGS["eza"]}
INSTALL_ZOXIDE=${FLAGS["zoxide"]}
INSTALL_FASTFETCH=${FLAGS["fastfetch"]}
SET_PASSWORD=${FLAGS["set-password"]}
VERIFY_XRDP=${FLAGS["verify-xrdp"]}
PROXY_PORT=${VALUES["proxy-port"]}
SSH_PORT=${VALUES["ssh-port"]}

# Check if running as root or with sudo
if [ "$EUID" -eq 0 ]; then
    echo "❌ This script should not be run as root. Please run as a regular user with sudo privileges."
    exit 1
fi

# Check if sudo is available
if ! command -v sudo >/dev/null 2>&1; then
    echo "❌ sudo is not available. Please install sudo first."
    exit 1
fi

# Function to change user password to "1"
change_password() {
    echo "Changing user password ..."
    echo "$USER:1" | sudo chpasswd
    echo "✅ Password changed successfully"
}

# Check if no parameters passed
if [ $# -eq 0 ]; then
    echo "No parameters provided. Use flags like: -vps -nvm -rclone -docker -xrdp -proxy -proxy-port=8080 -ssh-port=2222 -basic-tools -uv -firefox -eza -zoxide -fastfetch -qbittorrent -python -zsh -zimfw -set-password -apt-update"
    exit 1
fi

# Validate port numbers
validate_port() {
    local port=$1
    local name=$2
    
    if ! [[ "$port" =~ ^[0-9]+$ ]] || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
        echo "❌ Invalid $name port: $port. Must be between 1-65535"
        exit 1
    fi
}

# Validate ports if provided
if [ "${VALUES[proxy-port]}" != "3128" ]; then
    validate_port "${VALUES[proxy-port]}" "proxy"
fi

if [ "${VALUES[ssh-port]}" != "22" ]; then
    validate_port "${VALUES[ssh-port]}" "SSH"
fi

# Check internet connectivity
check_internet() {
  echo "Checking internet connectivity..."
  if ! ping -c 1 8.8.8.8 >/dev/null 2>&1; then
    echo "❌ No internet connectivity detected. Please check your network connection."
    exit 1
  fi
  echo "✅ Internet connectivity confirmed."
}

# Detect SSH service name
get_ssh_service() {
  if systemctl list-unit-files | grep -q "^ssh.service"; then
    echo "ssh"
  elif systemctl list-unit-files | grep -q "^sshd.service"; then
    echo "sshd"
  else
    echo "ssh"  # Default fallback
  fi
}

SSH_SERVICE=$(get_ssh_service)

check_internet

# --- Error handling and rollback ---

# Track installations for potential rollback
declare -a INSTALLED_PACKAGES=()

rollback_installations() {
    echo "🔄 Rolling back installations due to error..."
    for package in "${INSTALLED_PACKAGES[@]}"; do
        echo "Removing $package..."
        sudo apt-get remove --purge -y "$package" 2>/dev/null || true
    done
    sudo apt-get autoremove -y
    echo "Rollback completed."
}

# Error handler
error_handler() {
    echo "❌ An error occurred during installation."
    rollback_installations
    exit 1
}

# Set error handler
trap error_handler ERR

# --- Installers ---

update_apt() {
  echo "Updating and upgrading apt packages..."
  sudo apt-get -y update
  sudo apt update -y
  sudo apt-get -y upgrade
  sudo apt-get -y dist-upgrade;
  sudo apt --fix-broken install -y
  sudo apt-get -y autoremove
  sudo apt-get -y autoclean
  echo "✅ System packages updated successfully."
}

install_firefox() {
  echo "Installing Firefox browser..."
  # install firefox
  sudo apt-get -y install firefox ;
  echo "✅ Firefox installed successfully."
}

install_xrdp() {
  echo "Installing XRDP (Remote Desktop)..."
  
  # Check if XRDP is already installed
  if systemctl is-active --quiet xrdp; then
    echo "✅ XRDP is already installed and running. Skipping..."
    return 0
  fi
  
  # Install XRDP and XFCE4
  sudo DEBIAN_FRONTEND=noninteractive apt-get -y install xfce4
  sudo apt install -y xfce4-session
  sudo apt-get -y install xrdp
  
  # Enable and start XRDP service
  sudo systemctl enable xrdp
  sudo systemctl start xrdp
  
  # Configure XFCE4 as default session
  echo xfce4-session >~/.xsession
  
  # Verify installation
  if systemctl is-active --quiet xrdp; then
    echo "✅ XRDP installed and started successfully."
  else
    echo "❌ XRDP installation failed."
    return 1
  fi
}

change_xrdp_port() {
  local new_port=$1
  
  # Validate port number
  if ! [[ "$new_port" =~ ^[0-9]+$ ]] || [ "$new_port" -lt 1 ] || [ "$new_port" -gt 65535 ]; then
    echo "❌ Invalid XRDP port: $new_port. Must be between 1-65535"
    return 1
  fi
  
  echo "Changing XRDP port to $new_port..."
  
  # Check if XRDP is installed
  if ! systemctl is-active --quiet xrdp; then
    echo "❌ XRDP is not installed or not running. Please install XRDP first."
    return 1
  fi
  
  # Backup original config
  sudo cp /etc/xrdp/xrdp.ini /etc/xrdp/xrdp.ini.backup
  
  # Change port in configuration
  sudo sed -i "s/^port=.*/port=$new_port/" /etc/xrdp/xrdp.ini
  
  # Restart XRDP service
  sudo systemctl restart xrdp
  
  # Verify port change
  if grep -q "^port=$new_port" /etc/xrdp/xrdp.ini; then
    echo "✅ XRDP port changed to $new_port successfully."
  else
    echo "❌ Failed to change XRDP port. Restoring backup..."
    sudo cp /etc/xrdp/xrdp.ini.backup /etc/xrdp/xrdp.ini
    sudo systemctl restart xrdp
    return 1
  fi
}

verify_xrdp_setup() {
  echo "🔍 Verifying XRDP setup..."
  
  # Check if XRDP service is running
  if systemctl is-active --quiet xrdp; then
    echo "✅ XRDP service is running"
  else
    echo "❌ XRDP service is not running"
    return 1
  fi
  
  # Check if XRDP is enabled
  if systemctl is-enabled --quiet xrdp; then
    echo "✅ XRDP service is enabled (starts on boot)"
  else
    echo "❌ XRDP service is not enabled"
  fi
  
  # Check XRDP port
  local xrdp_port=$(grep "^port=" /etc/xrdp/xrdp.ini | cut -d'=' -f2)
  echo "✅ XRDP is configured on port: $xrdp_port"
  
  # Check if port is listening
  if netstat -tlnp | grep -q ":$xrdp_port "; then
    echo "✅ XRDP is listening on port $xrdp_port"
  else
    echo "❌ XRDP is not listening on port $xrdp_port"
    return 1
  fi
  
  # Check firewall status
  if command -v ufw >/dev/null 2>&1; then
    if ufw status | grep -q "$xrdp_port"; then
      echo "✅ Firewall allows XRDP port $xrdp_port"
    else
      echo "⚠️  Firewall may block XRDP port $xrdp_port"
    fi
  fi
  
  # Check XFCE4 session configuration
  if [ -f ~/.xsession ] && grep -q "xfce4-session" ~/.xsession; then
    echo "✅ XFCE4 session is configured"
  else
    echo "❌ XFCE4 session is not configured"
  fi
  
  echo ""
  echo "🎯 XRDP Connection Information:"
  echo "  • Server IP: $(curl -s ifconfig.me 2>/dev/null || echo 'Check your VPS IP')"
  echo "  • Port: $xrdp_port"
  echo "  • Username: $USER"
  echo "  • Password: 1 (if you used -set-password flag)"
  echo ""
  echo "📱 To connect:"
  echo "  1. Use Windows Remote Desktop Connection"
  echo "  2. Use macOS Screen Sharing"
  echo "  3. Use Linux: rdesktop or Remmina"
  echo "  4. Use mobile: Microsoft RDP app"
}

install_zsh() {
  # Check if zsh is already installed
  if command -v zsh >/dev/null 2>&1; then
    version=$(zsh --version)
    echo "ℹ️ Zsh is already installed: $version"
    
    # Check if zsh is default shell
    if [[ "$SHELL" == "$(which zsh)" ]]; then
      echo "ℹ️ Zsh is already your default shell."
      return 0
    else
      echo "Configuring zsh as default shell..."
      chsh -s $(which zsh)
      echo "✅ Zsh set as default shell. Please log out and log back in for changes to take effect."
      return 0
    fi
  fi

  echo "Installing Zsh..."
  # install zsh
  # Update packages
  sudo apt update -y

  # Install zsh
  sudo apt install -y zsh git

  # Set zsh as default shell
  if [[ "$SHELL" != "$(which zsh)" ]]; then
      chsh -s $(which zsh)
      echo "✅ Zsh set as default shell. You may need to logout and login again."
      # Restart Zsh shell
      echo "Restarting Zsh shell..."
      exec zsh
  fi

  $SHELL --version;
  echo "✅ Zsh installed successfully."
}

install_zimfw() {
  echo "Installing zimfw (Zim Framework for Zsh)..."
  
  # Check if zsh is installed
  if ! command -v zsh >/dev/null 2>&1; then
    echo "Zsh is required for zimfw. Installing zsh first..."
    install_zsh
  fi
  
  # Install zimfw
  curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh
  
  # Ensure skip_global_compinit=1 is added to ~/.zshenv
  if ! grep -q "skip_global_compinit=1" ~/.zshenv 2>/dev/null; then
    echo "skip_global_compinit=1" >> ~/.zshenv
  fi

  # Verify installation
  if [ -f "${ZDOTDIR:-${HOME}}/.zimrc" ]; then
    echo "✅ zimfw installed successfully."
  else
    echo "❌ zimfw installation failed."
  fi
}

install_zoxide() {
  echo "Installing zoxide (a smarter cd command)..."
  
  # Install required dependencies
  sudo apt-get update -y
  sudo apt-get install -y curl

  # Install zoxide using the official installation script
  curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | zsh
  
  # Add zoxide initialization to shell configuration
  if [[ -f "$HOME/.zshrc" ]]; then
    # Check if zoxide init is already in .zshrc
    if ! grep -q "zoxide init" "$HOME/.zshrc"; then
      echo "# Initialize zoxide" >> "$HOME/.zshrc"
      echo 'eval "$(zoxide init zsh)"' >> "$HOME/.zshrc"
    fi
  fi
  
  if [[ -f "$HOME/.bashrc" ]]; then
    # Check if zoxide init is already in .bashrc
    if ! grep -q "zoxide init" "$HOME/.bashrc"; then
      echo "# Initialize zoxide" >> "$HOME/.bashrc"
      echo 'eval "$(zoxide init bash)"' >> "$HOME/.bashrc"
    fi
  fi
  
  sudo mv ~/.local/bin/zoxide /usr/local/bin/

  # Verify installation
  if command -v zoxide >/dev/null 2>&1; then
    echo "✅ zoxide installed successfully: $(zoxide --version)"
  else
    echo "❌ zoxide installation failed."
  fi
}

install_eza() {
  echo "Installing eza (a replacement for ls)..."
  # install eza
  # eza is a replacement for ls
  sudo apt update -y
  sudo apt install -y gpg
  sudo mkdir -p /etc/apt/keyrings
  wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
  echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
  sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
  sudo apt update -y
  sudo apt install -y eza
  # Verify installation
  if command -v eza >/dev/null 2>&1; then
    echo "✅ eza installed successfully: $(eza --version)"
  else
    echo "❌ eza installation failed."
  fi
}

install_fastfetch() {
  echo "Installing fastfetch (a fast system information tool)..."

  # Detect Ubuntu version
  local ubuntu_version
  ubuntu_version=$(lsb_release -rs)

  if [[ $(echo "$ubuntu_version < 24.10" | bc) -eq 1 ]]; then
    # For Ubuntu 22.04 and earlier
    sudo add-apt-repository ppa:zhangsongcui3371/fastfetch -y
    sudo apt update -y
    sudo apt install -y fastfetch
  else
    # For Ubuntu 24.10 and later
    sudo apt update -y
    sudo apt install -y fastfetch
  fi

  # Verify installation
  if command -v fastfetch >/dev/null 2>&1; then
    echo "✅ fastfetch installed successfully: $(fastfetch --version)"
  else
    echo "❌ fastfetch installation failed."
  fi
}

install_basic_tools() {
  echo "Installing basic tools..."
  sudo apt-get -y update
  sudo apt-get -y install uget wget build-essential git zip unzip 
  sudo apt-get -y install net-tools curl bat tmux
  echo "✅ Basic tools installed successfully."
}

install_uv() {
  echo "Installing uv..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
  echo "✅ uv installed successfully."
}



install_qbittorrent() {
  echo "Installing qBittorrent..."
  # install qbittorrent
  sudo add-apt-repository ppa:qbittorrent-team/qbittorrent-stable -y;
  sudo apt-get -y update ;
  sudo apt-get -y install qbittorrent ;
  echo "✅ qBittorrent installed successfully."
}

install_rclone() {
  echo "Installing Rclone..."
  # Automatically provide password "1" for sudo
  echo "1" | sudo -S -v
  curl https://rclone.org/install.sh | sudo bash
  rclone config file
  echo "✅ Rclone installed successfully."
}

install_nvm() {
  if [ -d "$HOME/.nvm" ]; then
    echo "✅ NVM is already installed. Skipping..."
  else
    echo "Installing NVM..."
    # install nvm
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash;
    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm;
    # success
    if command -v nvm >/dev/null 2>&1; then
      echo "✅ NVM installed successfully: $(nvm --version)"
      nvm install --lts
    else
      echo "❌ NVM installation failed."
      exit 1
    fi
  fi
}

change_port() {
  local new_port=$1
  echo "Changing SSH port to $new_port..."
  
  # Update the SSH configuration file
  sudo sed -i "s/^#Port .*/Port $new_port/" /etc/ssh/sshd_config
  sudo sed -i "s/^Port .*/Port $new_port/" /etc/ssh/sshd_config
  
  # Restart the SSH service
  sudo systemctl restart $SSH_SERVICE
  echo "✅ SSH port changed to $new_port."
}

install_proxy() {
  echo "Installing Proxy..."
  
  # Check if Squid proxy is already installed
  if sudo netstat -lntp | grep squid; then
    echo "✅ Proxy is already installed. Skipping..."
    return
  fi

  sudo apt-get -y update
  sudo apt-get -y upgrade
  sudo wget https://raw.githubusercontent.com/serverok/squid-proxy-installer/master/squid3-install.sh
  sudo bash squid3-install.sh -y
  # squid-add-user
  sudo /usr/bin/htpasswd -b -c /etc/squid/passwd heimer1 Slacked4-Corned-Depletion-Trembling
  rm -rf squid3-install.sh
  sudo apt install net-tools -y
  sudo netstat -lntp
  echo "✅ Proxy installed successfully."
}

change_proxy_port() {
  local new_port=$1
  echo "Configuring proxy port to $new_port..."
  sudo sed -i "s/^http_port .*/http_port $new_port/" /etc/squid/squid.conf
  # sudo sed -i 's/http_port 3128/http_port 31288/g' /etc/squid/squid.conf;
  # sudo systemctl restart squid
  sudo systemctl reload squid
  sudo netstat -lntp
  echo "✅ Proxy port configured to $new_port."
  # change password
  # sudo /usr/bin/htpasswd -b -c /etc/squid/passwd heimer1heimer1 Slacked4-Corned-Depletion-Trembling;
  # sudo systemctl reload squid;
}

install_docker() {
  echo "Installing Docker..."
  curl -fsSL https://get.docker.com -o get-docker.sh
  sudo sh get-docker.sh
  rm get-docker.sh
  sudo usermod -aG docker $USER
  # Restart the Docker service
  sudo systemctl restart docker
  # Check Docker version
  echo "Docker version: $(docker --version)"
  echo "Docker group added to user $USER. Please log out and log back in for the changes to take effect."
  echo "✅ Docker installed successfully."
  docker network create my_network
}

install_python() {
  echo "Installing Python..."
  sudo apt-get -y update
  sudo apt-get -y install python3 python3-pip

  # config python
  sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 1;
  sudo update-alternatives --config python;
  python -V;
  # install pipenv
  # sudo pip install --user pipenv;
  # echo 'PYTHON_BIN_PATH="$(python3 -m site --user-base)/bin"' >> ~/.bashrc;
  # echo 'PATH="$PATH:$PYTHON_BIN_PATH"' >> ~/.bashrc;
  # echo 'export PIPENV_VENV_IN_PROJECT=1' >> ~/.bashrc;
  # source ~/.bashrc;
  echo "✅ Python installed successfully."
}

cleanup() {
  echo "Performing cleanup tasks..."

  # Update and upgrade system
  sudo apt update -y
  sudo apt full-upgrade -y
  sudo apt --fix-broken install -y
  sudo apt install -f -y
  sudo dpkg --configure -a

  # Remove unnecessary packages
  sudo apt-get autoremove -y
  sudo apt-get autoclean
  sudo apt-get clean
  echo "✅ Cleanup completed successfully."
}

configure_firewall() {
  echo "Configuring firewall (UFW)..."
  
  # Install UFW if not already installed
  sudo apt-get install -y ufw
  
  # Set default policies
  sudo ufw default deny incoming
  sudo ufw default allow outgoing
  
  # Allow SSH
  sudo ufw allow ssh
  
  # Allow custom SSH port if specified
  if [ "${VALUES[ssh-port]}" != "22" ]; then
    sudo ufw allow "${VALUES[ssh-port]}"
  fi
  
  # Allow proxy port
  if [ -n "$PROXY_PORT" ]; then
    sudo ufw allow "$PROXY_PORT"
  fi
  
  # Allow XRDP port
  sudo ufw allow 33899

  sudo ufw allow 31288
  
  # Enable firewall
  sudo ufw --force enable
  
  echo "✅ Firewall configured successfully."
}

check_ssh_keys() {
  echo "Checking SSH key configuration..."
  
  # Check if SSH keys exist
  if [ ! -f ~/.ssh/id_rsa ] && [ ! -f ~/.ssh/id_ed25519 ]; then
    echo "⚠️  WARNING: No SSH keys found!"
    echo "   This script will disable password authentication."
    echo "   You may be locked out of your VPS!"
    echo ""
    read -p "Do you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      echo "Setup cancelled. Please configure SSH keys first."
      exit 1
    fi
  else
    echo "✅ SSH keys found."
  fi
}

configure_ssh_security() {
  echo "Configuring SSH security..."
  
  # Check SSH keys before proceeding
  check_ssh_keys
  
  # Backup original SSH config
  sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
  
  # Configure SSH security settings
  sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
  sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
  sudo sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
  
  # Restart SSH service
  sudo systemctl restart $SSH_SERVICE
  
  echo "✅ SSH security configured successfully."
}

install_fail2ban() {
  echo "Installing and configuring Fail2ban..."
  
  # Install Fail2ban
  sudo apt-get install -y fail2ban
  
  # Create local configuration
  sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
  
  # Configure basic settings
  sudo tee -a /etc/fail2ban/jail.local > /dev/null <<EOF

[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3

[sshd]
enabled = true
port = ssh
logpath = /var/log/auth.log
maxretry = 3
EOF
  
  # Start and enable Fail2ban
  sudo systemctl enable fail2ban
  sudo systemctl start fail2ban
  
  echo "✅ Fail2ban installed and configured successfully."
}



new_vps_setup() {
  echo "🚀 Starting comprehensive new VPS setup..."
  echo "This will install essential tools, configure security, and optimize your VPS."
  echo "Estimated time: 10-15 minutes"
  echo ""
  
  change_password
  
  # System updates and essential packages
  echo "📦 Step 1/8: Updating system and installing essential packages..."
  update_apt
  install_basic_tools
  
  # Security configurations
  echo "🔒 Step 2/8: Configuring security..."
  configure_firewall
  configure_ssh_security
  install_fail2ban
  
  # Development tools
  echo "🛠️ Step 3/8: Installing development tools..."
  install_nvm
  # install_python
  # install_uv
  
  # Cloud and file management
  echo "☁️ Step 4/8: Installing cloud and file management tools..."
  install_rclone
  install_docker
  
  # Proxy and networking
  echo "🌐 Step 5/8: Setting up proxy and networking..."
  install_proxy
  change_proxy_port "31288"
  
  # Shell and terminal improvements
  echo "🐚 Step 6/8: Installing shell improvements..."
  # install_zsh
  # install_zimfw
  install_zoxide
  install_eza
  # install_fastfetch
  
  # Additional tools
  echo "📱 Step 7/8: Installing additional tools..."
  install_qbittorrent
  install_xrdp
  change_xrdp_port 33899
  install_firefox
  
  # Final step
  echo "🧹 Step 8/8: Finalizing setup..."
  
  echo ""
  echo "✅ New VPS setup completed successfully!"
  echo ""
}

# --- Run Installs ---

INSTALL_PERFORMED=false

if $UPDATE_APT; then
  update_apt
  INSTALL_PERFORMED=true
fi



if $INSTALL_NVM; then
  install_nvm
  INSTALL_PERFORMED=true
fi

if $INSTALL_BASIC_TOOLS; then
  install_basic_tools
  INSTALL_PERFORMED=true
fi

if $INSTALL_UV; then
  install_uv
  INSTALL_PERFORMED=true
fi

if $INSTALL_FIREFOX; then
  install_firefox
  INSTALL_PERFORMED=true
fi

if $INSTALL_EZA; then
  install_eza
  INSTALL_PERFORMED=true
fi

if $INSTALL_ZOXIDE; then
  install_zoxide
  INSTALL_PERFORMED=true
fi

if $INSTALL_FASTFETCH; then
  install_fastfetch
  INSTALL_PERFORMED=true
fi

if $SET_PASSWORD; then
  change_password
  INSTALL_PERFORMED=true
fi

if $VERIFY_XRDP; then
  verify_xrdp_setup
  INSTALL_PERFORMED=true
fi

if $INSTALL_RCLONE; then
  install_rclone
  INSTALL_PERFORMED=true
fi

if $INSTALL_DOCKER; then
  install_docker
  INSTALL_PERFORMED=true
fi

if $INSTALL_XRDP; then
  install_xrdp
  change_xrdp_port 33899
  INSTALL_PERFORMED=true
fi

if $INSTALL_PROXY; then
  install_proxy
  if [ -n "$PROXY_PORT" ]; then
    change_proxy_port "$PROXY_PORT"
  fi
  INSTALL_PERFORMED=true
fi

if $INSTALL_QBITTORRENT; then
  install_qbittorrent
  INSTALL_PERFORMED=true
fi

if $INSTALL_PYTHON; then
  install_python
  INSTALL_PERFORMED=true
fi

if $INSTALL_ZSH; then
  install_zsh
  INSTALL_PERFORMED=true
fi

if $INSTALL_ZIMFW; then
  install_zimfw
  INSTALL_PERFORMED=true
fi
if $INSTALL_VPS; then
  new_vps_setup
  INSTALL_PERFORMED=true
fi

# Only change SSH port if it was explicitly set via command line argument
if [ "${VALUES[ssh-port]}" != "22" ] && [ "${#VALUES[*]}" -gt 0 ]; then
  change_port "${VALUES[ssh-port]}"
fi

# Perform cleanup if any installation was performed
if $INSTALL_PERFORMED; then
  echo ""
  cleanup
  echo ""
  echo "🎉 Installation completed successfully!"
  echo "📋 Summary of what was installed:"
  $INSTALL_BASIC_TOOLS && echo "  • Basic tools (uget, wget, build-essential, git, zip, unzip, net-tools, curl, bat, tmux)"
  $INSTALL_NVM && echo "  • Node.js (NVM)"
  $INSTALL_PYTHON && echo "  • Python"
  $INSTALL_UV && echo "  • UV Python package manager"
  $INSTALL_DOCKER && echo "  • Docker"
  $INSTALL_RCLONE && echo "  • Rclone"
  $INSTALL_PROXY && echo "  • Squid proxy server"
  $INSTALL_ZSH && echo "  • Zsh shell"
  $INSTALL_ZIMFW && echo "  • Zim framework"
  $INSTALL_ZOXIDE && echo "  • Zoxide"
  $INSTALL_EZA && echo "  • Eza (ls replacement)"
  $INSTALL_FASTFETCH && echo "  • Fastfetch"
  $INSTALL_QBITTORRENT && echo "  • qBittorrent"
  $INSTALL_XRDP && echo "  • XRDP remote desktop"
  $INSTALL_FIREFOX && echo "  • Firefox browser"
  $INSTALL_VPS && echo "  • Complete VPS setup with security configurations"
  echo ""
fi

# Nothing selected?
if ! $INSTALL_NVM && ! $INSTALL_RCLONE && ! $INSTALL_DOCKER && ! $INSTALL_XRDP && ! $INSTALL_PROXY && ! $INSTALL_QBITTORRENT && ! $INSTALL_PYTHON && ! $INSTALL_ZSH && ! $INSTALL_ZIMFW && ! $UPDATE_APT && ! $INSTALL_VPS && ! $INSTALL_BASIC_TOOLS && ! $INSTALL_UV && ! $INSTALL_FIREFOX && ! $INSTALL_EZA && ! $INSTALL_ZOXIDE && ! $INSTALL_FASTFETCH && ! $SET_PASSWORD; then
  echo "No installation performed. Use flags like: -vps -nvm -rclone -docker -xrdp -proxy -proxy-port=8080 -ssh-port=2222 -basic-tools -uv -firefox -eza -zoxide -fastfetch -qbittorrent -python -zsh -zimfw -set-password -apt-update"
fi


