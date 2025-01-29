#!/bin/bash

GITHUB_USERNAME=William-Fernandes252

# Purge snap
sudo snap remove --purge \
  firefox \
  bare  \
  core22 \
  firmware-updater \
  gnome-42-2204 \
  gtk-common-themes \
  snap-store \
  snapd \
  snapd-desktop-integration \
  thunderbird
sudo apt remove --autoremove snapd -y

# Uninstall system pre-installed Docker
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt remove $pkg; done

# Add GitHub CLI repository
sudo mkdir -p -m 755 /etc/apt/keyrings \
&& sudo wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \

# Add GCP repository
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

# Add VSCode repository
sudo wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
sudo rm -f packages.microsoft.gpg

# Add Docker repository
sudo install -m 0755 -d /etc/apt/keyrings
sudo wget -q --show-progress --https-only --retry-connrefused -O /etc/apt/keyrings/docker.asc https://download.docker.com/linux/ubuntu/gpg
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update repositories
sudo apt update -y
sudo apt upgrade -y

# Install basic programs and libraries
sudo apt install -y \
  curl \
  build-essential \
  git \
  zsh \
  cargo \
  zlib1g-dev \
  libffi-dev \
  libssl-dev \
  libbz2-dev \
  libreadline-dev \
  libsqlite3-dev \
  liblzma-dev \
  libncurses-dev \
  tk-dev \
  libgmp-dev \
  libgmp10 \
  wget \
  gpg \
  apt-transport-https \
  ca-certificates \
  gnupg \
  flatpak \
  gnome-software-plugin-flatpak \
  gh \
  google-cloud-cli \
  code \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin \

# Add Flathub repository
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Make ZSH the default shell
chsh -s $(which zsh)

# Install AWS CLI
sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
sudo unzip /tmp/awscliv2.zip -d /tmp
sh /tmp/aws/install

# Manage Docker as non-root
sudo groupadd docker
sudo usermod -aG docker $USER
sudo newgrp docker
sudo chown "$USER":"$USER" /home/"$USER"/.docker -R
sudo chmod g+rwx "$HOME/.docker" -R

# Install remaining programs
sudo flatpak install -y com.google.Chrome org.mozilla.Thunderbird com.bitwarden.desktop rest.insomnia.Insomnia nz.mega.MEGAsync
cargo install zoxide bat exa ripgrep git-delta
curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
sh -c "$(curl -fsLS get.chezmoi.io)"
curl -sS https://starship.rs/install.sh | sh
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
curl -sSL https://install.python-poetry.org | python3 -
curl -fsSL https://get.pnpm.io/install.sh | sh -
pnpm install -g @bitwarden/cli

# Install Oh My Zsh plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/asdf-vm/asdf.git ~/.asdf

# Fix SSH keys ownership, permissions and mode
sudo chown -R $USER:$USER ~/.ssh
sudo chmod 700 ~/.ssh
sudo chmod 600 ~/.ssh/id_ed25519
sudo chmod 644 ~/.ssh/id_ed25519.pub
sudo chmod 600 ~/.ssh/authorized_keys
sudo chmod 644 ~/.ssh/known_hosts

# Initialize Chezmoi
chezmoi init --ssh $GITHUB_USERNAME
chezmoi update

# Finalize
sudo apt -y autoremove
sudo apt -y autoclean
reboot
