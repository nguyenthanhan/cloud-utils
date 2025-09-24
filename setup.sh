#!/bin/bash

# chmod +x setup.sh

# example usage: ./setup.sh -small-essential;

#chmod +x setup.sh;
#./setup.sh;

# Define arrays for flags and their default values
declare -A FLAGS=(
  ["essential"]=false
  ["se"]=false
  ["nvm"]=false
  ["rclone"]=false
  ["docker"]=false
  ["xrdp"]=false
  ["proxy"]=false
  ["pkg"]=false
  ["qbittorrent"]=false
  ["python"]=false
  ["zsh"]=false
  ["zimfw"]=false
  ["apt-update"]=true
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
ESSENTIAL=${FLAGS["essential"]}
SMALL_ESSENTIAL=${FLAGS["se"]}
INSTALL_NVM=${FLAGS["nvm"]}
INSTALL_RCLONE=${FLAGS["rclone"]}
INSTALL_DOCKER=${FLAGS["docker"]}
INSTALL_XRDP=${FLAGS["xrdp"]}
INSTALL_PROXY=${FLAGS["proxy"]}
INSTALL_PACKAGES=${FLAGS["pkg"]}
INSTALL_QBITTORRENT=${FLAGS["qbittorrent"]}
INSTALL_PYTHON=${FLAGS["python"]}
INSTALL_ZSH=${FLAGS["zsh"]}
INSTALL_ZIMFW=${FLAGS["zimfw"]}
UPDATE_APT=${FLAGS["apt-update"]}
PROXY_PORT=${VALUES["proxy-port"]}
SSH_PORT=${VALUES["ssh-port"]}

# Check if no parameters passed
if [ $# -eq 0 ]; then
    echo "No parameters provided. Use flags like: -essential -se -nvm -rclone -docker -xrdp -proxy -proxy-port=8080 -ssh-port=2222 -pkg -qbittorrent -python -zsh -zimfw -zoxide -apt-update"
    exit 1
fi

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

install_optional_package() {
  echo "Force installing optional package..."
  # install optional package
  sudo apt-get -y install firefox ;
  echo "✅ Optional package installed successfully."
}

install_xrdp() {
  # install xrdp
  sudo DEBIAN_FRONTEND=noninteractive apt-get -y install xfce4;
  sudo apt install xfce4-session;
  sudo apt-get -y install xrdp;
  sudo systemctl enable xrdp;
  echo xfce4-session >~/.xsession;
  sudo service xrdp restart;
  install_optional_package
}

change_xrdp_port() {
  local new_port=$1
  echo "Changing XRDP port to $new_port..."
  sudo sed -i "s/^port=.*/port=$new_port/" /etc/xrdp/xrdp.ini
  sudo systemctl restart xrdp
  echo "✅ XRDP port changed to $new_port."

  # sudo sed -i 's/port=3389/port=33897/g' /etc/xrdp/xrdp.ini;
  # sudo service xrdp restart ;
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

install_s_package() {
  echo "Force installing small package..."
  # install package
  sudo apt-get -y update
  sudo apt-get -y install uget wget build-essential git zip unzip 
  sudo apt-get -y install net-tools curl zsh bat tmux

  install_eza
  install_zoxide

  echo "✅ Package installed small successfully."
}

install_package() {
  echo "Force installing package..."
  # install package

  install_s_package

  # install uv
  echo "Installing uv..."
  curl -LsSf https://astral.sh/uv/install.sh | sh

  echo "✅ Package installed successfully."
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
  sudo -v ; curl https://rclone.org/install.sh | sudo zsh;
  rclone config file;
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
  sudo systemctl restart sshd
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

essential_setup() {
  echo "Performing essential setup tasks..."
  
  update_apt
  install_zsh
  install_zimfw
  install_package
  install_nvm
  install_rclone
  install_proxy
  change_proxy_port "31288"
  install_docker
  # install_xrdp
  # change_xrdp_port 33899 # Change to desired port if needed
  # change_proxy_port "$PROXY_PORT"
  # install_qbittorrent
  # install_python
  # Change SSH port if specified
  # change_port "22"
  # Perform cleanup if any installation was performed
  cleanup

  echo "✅ Essential setup completed successfully."
}

small_essential_setup() {
  echo "Performing small essential setup tasks..."
  
  update_apt
  install_zsh
  install_zimfw
  install_s_package
  install_nvm
  install_rclone
  install_proxy
  change_proxy_port "31288"
  install_docker
  # Perform cleanup
  cleanup

  echo "✅ Small essential setup completed successfully."
}

# --- Run Installs ---

INSTALL_PERFORMED=false

if $UPDATE_APT; then
  update_apt
  INSTALL_PERFORMED=true
fi

if $SMALL_ESSENTIAL; then
  small_essential_setup
  INSTALL_PERFORMED=true
elif $ESSENTIAL; then
  essential_setup
  INSTALL_PERFORMED=true
fi

if $INSTALL_NVM; then
  install_nvm
  INSTALL_PERFORMED=true
fi

if $INSTALL_PACKAGES; then
  install_package
  INSTALL_PERFORMED=true
fi

$INSTALL_RCLONE && { install_rclone; INSTALL_PERFORMED=true; }
$INSTALL_DOCKER && { install_docker; INSTALL_PERFORMED=true; }
$INSTALL_XRDP && { 
  install_xrdp
  INSTALL_PERFORMED=true
  change_xrdp_port 33899 # Change to desired port if needed
}
if $INSTALL_PROXY; then
  install_proxy
  if [ -n "$PROXY_PORT" ]; then
    change_proxy_port "$PROXY_PORT" # Ensure proxy port is updated
  fi
  INSTALL_PERFORMED=true
fi
$INSTALL_QBITTORRENT && { install_qbittorrent; INSTALL_PERFORMED=true; }
$INSTALL_PYTHON && { install_python; INSTALL_PERFORMED=true; }
$INSTALL_ZSH && { install_zsh; INSTALL_PERFORMED=true; }
$INSTALL_ZIMFW && { install_zimfw; INSTALL_PERFORMED=true; }

# Only change SSH port if it was explicitly set via command line argument
if [ "${VALUES[ssh-port]}" != "22" ] && [ "${#VALUES[*]}" -gt 0 ]; then
  change_port "${VALUES[ssh-port]}"
fi

# Perform cleanup if any installation was performed
if $INSTALL_PERFORMED; then
  cleanup
fi

# Nothing selected?
if ! $ESSENTIAL && ! $SMALL_ESSENTIAL && ! $INSTALL_NVM && ! $INSTALL_RCLONE && ! $INSTALL_DOCKER && ! $INSTALL_XRDP && ! $INSTALL_PROXY && ! $INSTALL_QBITTORRENT && ! $INSTALL_PYTHON && ! $INSTALL_ZSH && ! $INSTALL_ZIMFW && ! $INSTALL_PACKAGES && ! $UPDATE_APT; then
  echo "No installation performed. Use flags like: -essential -se -nvm -rclone -docker -xrdp -proxy -proxy-port=8080 -ssh-port=2222 -pkg -qbittorrent -python -zsh -zimfw -zoxide -apt-update"
fi

