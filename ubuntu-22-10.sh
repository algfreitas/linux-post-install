#!/usr/bin/bash
# Description: Script for enviroment configuration for Ubuntu 22.10+
# Author: André L G Freitas
# Date: 2022/22/12

# Verify for sudo/root execution
if [ "$EUID" -ne 0 ]
  then echo "Por favor, execute o script como sudo!"
  exit
fi

# Get the Real Username
RUID=$(who | awk 'FNR == 1 {print $1}')

# Translate Real Username to Real User ID
RUSER_UID=$(id -u ${RUID})

# Full system upgrade
apt-get update
apt-get -f install -y
apt-get dist-upgrade -y

apt-get install \
 ansible \
 cabextract \
 curl \
 ubuntu-restricted-extras \
 p7zip-full \
 openjdk-19-jre \
 openjdk-19-jdk \
 git \
 git-flow \
 docker.io \
 docker-compose \
 htop \
 zenity \
 ssh-askpass \
 zram-config \
 build-essential \
 dkms \
 perl \
 wget \
 gcc \
 make \
 default-libmysqlclient-dev \
 libssl-dev \
 zlib1g-dev \
 libbz2-dev \
 libreadline-dev \
 libsqlite3-dev \
 llvm \
 libncurses5-dev \
 libncursesw5-dev \
 xz-utils \
 tk-dev \
 libffi-dev \
 liblzma-dev \
 fonts-firacode \
 virtualbox \
 vlc \
 vagrant \
 -y
 
# Install OpenVPN packages for Gnome
apt-get install \
 network-manager-openvpn \
 network-manager-openvpn-gnome \
 openvpn-systemd-resolved \
 -y

# Install Python dev packages
apt-get install \
 python3-full \
 python3-dev \
 python3-openssl \
 -y
 
# pyenv install
curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash  

# Install Discord
wget --no-check-certificate "https://discord.com/api/download?platform=linux&format=deb" -O discord.deb
dpkg -i discord.deb
rm -Rf discord.deb

# Install Google Chrome
wget --no-check-certificate "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" -O chrome.deb
dpkg -i chrome.deb
rm -Rf chrome.deb

# Install VSCode
wget "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" -O vscode.deb
dpkg -i vscode.deb
rm -Rf vscode.deb

# Install OpenLens
wget "https://github.com/MuhammedKalkan/OpenLens/releases/download/v$(curl -L -s https://raw.githubusercontent.com/MuhammedKalkan/OpenLens/main/version)/OpenLens-$(curl -L -s https://raw.githubusercontent.com/MuhammedKalkan/OpenLens/main/version).amd64.deb" -O openlens.deb
dpkg -i openlens.deb
rm -Rf openlens.deb

# Install Kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm -rf kubectl

# Install Helm
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

# Install kubectx and kubectl
git clone https://github.com/ahmetb/kubectx /opt/kubectx
ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
ln -s /opt/kubectx/kubens /usr/local/bin/kubens

# Install Kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.17.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Add current user to Docker group
usermod -aG docker $SUDO_USER

# Add current user for print group
usermod -aG lpadmin $SUDO_USER

# Add current user for vboxuser group
usermod -aG vboxusers $SUDO_USER

# Fix for IntelliJ/PyCharm
echo "fs.inotify.max_user_watches = 524288" >> /etc/sysctl.conf

# Install Windows 10 fonts
sudo -u $SUDO_USER mkdir /home/$SUDO_USER/.fonts
sudo -u $SUDO_USER wget -qO- http://plasmasturm.org/code/vista-y --noninteractivefonts-installer/vistafonts-installer | sudo -u $SUDO_USER bash
rm -rf /home/$SUDO_USER/PowerPointViewer.exe

# Install Microsoft Fonts
mkdir -p /usr/share/fonts/truetype/msttcorefonts
mkdir -p /tmp/ttf

wget "https://mirrors.kernel.org/gentoo/distfiles/andale32.exe" -O /tmp/ttf/andale32.exe
wget "https://mirrors.kernel.org/gentoo/distfiles/arial32.exe" -O /tmp/ttf/arial32.exe
wget "https://mirrors.kernel.org/gentoo/distfiles/arialb32.exe" -O /tmp/ttf/arialb32.exe
wget "https://mirrors.kernel.org/gentoo/distfiles/comic32.exe" -O /tmp/ttf/comic32.exe
wget "https://mirrors.kernel.org/gentoo/distfiles/courie32.exe" -O /tmp/ttf/courie32.exe
wget "https://mirrors.kernel.org/gentoo/distfiles/georgi32.exe" -O /tmp/ttf/georgi32.exe
wget "https://mirrors.kernel.org/gentoo/distfiles/impact32.exe" -O /tmp/ttf/impact32.exe
wget "https://mirrors.kernel.org/gentoo/distfiles/times32.exe" -O /tmp/ttf/times32.exe
wget "https://mirrors.kernel.org/gentoo/distfiles/trebuc32.exe" -O /tmp/ttf/trebuc32.exe
wget "https://mirrors.kernel.org/gentoo/distfiles/verdan32.exe" -O /tmp/ttf/verdan32.exe
wget "https://mirrors.kernel.org/gentoo/distfiles/webdin32.exe" -O /tmp/ttf/webdin32.exe
wget "https://raw.githubusercontent.com/PrincetonUniversity/COS333_Comet/master/android/app/src/main/assets/fonts/Microsoft%20Sans%20Serif.ttf" -O /usr/share/fonts/truetype/msttcorefonts/ms-sans-serif.ttf 

cabextract /tmp/ttf/*.exe -d /tmp/ttf
cp /tmp/ttf/*.TTF /usr/share/fonts/truetype/msttcorefonts
rm -rf /tmp/ttf
fc-cache -fv

# Set Chrome for default browser
sudo -u $SUDO_USER xdg-settings set default-web-browser google-chrome.desktop

# Set multiples desktop only for primary monitor
sudo -u ${RUID} DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/${RUSER_UID}/bus" gsettings set org.gnome.mutter workspaces-only-on-primary true

# Set Swap and Zram
swapoff /swapfile
rm -rf /swapfile
dd if=/dev/zero of=/swapfile bs=8192 count=1048576
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
systemctl enable zram-config
systemctl start zram-config

# Generate SSH Key for git
sudo -u $SUDO_USER ssh-keygen -q -t rsa -N '' -f /home/$SUDO_USER/.ssh/id_rsa
clear
echo "Sua chave."
echo ""
cat /home/$SUDO_USER/.ssh/id_rsa.pub
echo ""
read -p "Quando estiver pronto, pressione qualquer tecla para continuar... " temp </dev/tty

# Set global git configuration
clear
echo "Credenciais locais do git."
echo ""
echo "Nome e sobrenome: "  
read nome </dev/tty
echo "E-mail: "  
read email </dev/tty
sudo -u $SUDO_USER git config --global user.name "$nome"
sudo -u $SUDO_USER git config --global user.email "$email"
clear

# Clean
apt clean
apt autoremove -y

# End script
clear
echo "Fim!"
