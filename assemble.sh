#!/bin/bash

GITHUB_USERNAME=William-Fernandes252

# Update repositories
apt update -y
apt upgrade -y

# Purge snap
snap remove --purge firefox
snap remove --purge bare 
snap remove --purge core22
snap remove --purge firmware-updater
snap remove --purge gnome-42-2204
snap remove --purge gtk-common-themes
snap remove --purge snap-store
snap remove --purge snapd
snap remove --purge snapd-desktop-integration
snap remove --purge thunderbird
apt remove --autoremove snapd -y

# Install Flatpak
apt install flatpak gnome-software-plugin-flatpak -y
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Install basic programs and libraries
apt install -y \
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
  libgmp10

# Make ZSH the default shell
chsh -s $(which zsh)

# Install Github CLI
(type -p wget >/dev/null || (apt update && apt-get install wget -y)) \
&& mkdir -p -m 755 /etc/apt/keyrings \
&& wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
&& chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
&& apt update \
&& apt install gh -y

# Install VSCode
apt-get install wget gpg
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
rm -f packages.microsoft.gpg
apt install apt-transport-https
apt update
apt install code

# Uninstall system pre-installed Docker
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do apt-get remove $pkg; done

# Add Docker's official GPG key:
apt-get update
apt-get install ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update

# Install Docker
apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Manage Docker as non-root
groupadd docker
usermod -aG docker $USER
newgrp docker
chown "$USER":"$USER" /home/"$USER"/.docker -R
chmod g+rwx "$HOME/.docker" -R

# Install remaining programs
flatpak install -y com.google.Chrome org.mozilla.Thunderbird com.bitwarden.desktop rest.insomnia.Insomnia nz.mega.MEGAsync
cargo install zoxide bat exa ripgrep
curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply William-Fernandes252
curl -sS https://starship.rs/install.sh | sh
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
curl -sSL https://install.python-poetry.org | python3 -
curl -fsSL https://get.pnpm.io/install.sh | sh -

# Install Oh My Zsh plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/asdf-vm/asdf.git ~/.asdf

# Fix SSH keys ownership, permissions and mode
chown -R $USER:$USER ~/.ssh
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
chmod 600 ~/.ssh/authorized_keys
chmod 644 ~/.ssh/known_hosts

# Initialize Chezmoi
chezmoi init --ssh $GITHUB_USERNAME
chezmoi update

# Login on Atuin
atuin login

# Finalize
apt -y autoremove
apt -y autoclean
reboot
