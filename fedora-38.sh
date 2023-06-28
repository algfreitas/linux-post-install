#!/usr/bin/bash
# Description: Script for enviroment configuration for Fedora 38
# Author: André L G Freitas
# Date: 2023/05/12

# Verify for sudo/root execution
if [ "$EUID" -ne 0 ]
  then echo "Por favor, execute o script como sudo!"
  exit
fi

# Get the Real Username
RUID=$(who | awk 'FNR == 1 {print $1}')

# Translate Real Username to Real User ID
RUSER_UID=$(id -u ${RUID})

# DNF
echo 'max_parallel_downloads=10' | tee -a /etc/dnf/dnf.conf
echo 'deltarpm=true' | tee -a /etc/dnf/dnf.conf

# Full system upgrade
dnf upgrade --refresh -y
dnf group update core -y
sudo -u $SUDO_USER flatpak update -y --noninteractive

# Enable fstrim
systemctl enable fstrim.timer

# Install basic packages
dnf install \
 p7zip \
 htop \
 openssh-askpass \
 gnome-extensions-app \
 gnome-tweaks \
 flameshot \
 -y

# Install dev packages
dnf install \
 git \
 ansible \
 helm \
 vagrant \
 docker \
 docker-compose \
 buildah \
 -y 

# Install Kernel Dev Packages
dnf install \
 kernel-headers \
 kernel-devel \
 dkms \
 -y

dnf -y install @development-tools 

# Install Python dev packages
dnf install \
 python-wheel \
 python-devel \
 python-virtualenv \
 -y

# Install VSCode
rpm --import https://packages.microsoft.com/keys/microsoft.asc
sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
dnf check-update
dnf install code -y

# Install Kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm -rf kubectl

# Install kubectx and kubectl
git clone https://github.com/ahmetb/kubectx /opt/kubectx
ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
ln -s /opt/kubectx/kubens /usr/local/bin/kubens

# Install Kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.17.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

####### or ##########################################################

# Install Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-latest.x86_64.rpm
sudo rpm -Uvh minikube-latest.x86_64.rpm
rm -rf minikube-latest.x86_64.rpm

# Intall Open Lens.
wget "https://github.com/MuhammedKalkan/OpenLens/releases/download/v$(curl -L -s https://raw.githubusercontent.com/MuhammedKalkan/OpenLens/main/version)/OpenLens-$(curl -L -s https://raw.githubusercontent.com/MuhammedKalkan/OpenLens/main/version).x86_64.rpm" -O openlens.rpm
dnf install openlens.rpm -y
rm -rf openlens.rpm

# Install CTop.
sudo wget https://github.com/bcicen/ctop/releases/download/v0.7.7/ctop-0.7.7-linux-amd64 -O /usr/local/bin/ctop
sudo chmod +x /usr/local/bin/ctop

# Add helm repo bitnami
helm repo add bitnami https://charts.bitnami.com/bitnami

##########################################################################
# Install Nvidia Drivers – RPM Fusion Method.
dnf install akmod-nvidia -y

# You can also install the CUDA driver’s support if required.
dnf install xorg-x11-drv-nvidia-cuda -y
###########################################################################

# Add current user to Docker group
usermod -aG docker $SUDO_USER

# Add current user for print group
usermod -aG lpadmin $SUDO_USER

# Adicionar chave SSH ao sistema
update-crypto-policies --set DEFAULT:FEDORA32
sudo -u $SUDO_USER ssh-keygen -q -t rsa -N '' -f /home/$SUDO_USER/.ssh/id_rsa
clear
echo ""
cat /home/$SUDO_USER/.ssh/id_rsa.pub
echo ""
read -p "Quando estiver pronto, pressione qualquer tecla para continuar... " temp </dev/tty

# Generate SSH Key for git
clear
echo "Agora vamos configurar suas credenciais globais do git."
echo ""
echo "Nome e sobrenome: "  
read nome </dev/tty
echo "E-mail: "  
read email </dev/tty
sudo -u $SUDO_USER git config --global user.name "$nome"
sudo -u $SUDO_USER git config --global user.email "$email"
clear

# Clean
dnf autoremove -y
pkcon refresh force -c -1

# Alert
clear
read -p "Finalizado." temp </dev/tty

# Bye :)
