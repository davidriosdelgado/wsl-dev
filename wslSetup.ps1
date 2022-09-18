'''
Packages list:
    - Code 
        Python 3.x -
        Python PIP -
        jq -
        Powershell -
        Go -
        Git -
    - Kubernetes
        kubectl -
        calicoctl -
        Helm -
        Kustomize -
        etcd client
        Openshift -
        Argo Cli
        podman -
        buildah -
        skopeo -
    - S3 Management
        Minio Client
    - Cloud Management
        AWS cli
        Azure cli
    - IaC
        Terraform -
        Packer -
        Calm-DSL
    - Cli
        Vault-Cli -

'''

# Configure WSL
# -------------
##list wsl containes
wsl -l -v

##set wsl version 2 by default
wsl --set-default-version 2

##change wsl version for an existing wsl deployment 
wsl --set-version <wsl image name> 2


# Configure WSL image
# -------------------

# Set values
OS_FAMILY=$(cat /etc/os-release | grep ID_LIKE | sed 's/=/ /g' | sed 's/"//g' | awk '{print $2}')
OS_VERSION=$(cat /etc/os-release | grep VERSION | sed 's/=/ /g' | sed 's/"//g' | awk '{print $2}')
if [ $(cat /etc/os-release | grep ID_LIKE | sed 's/=/ /g' | sed 's/"//g' | awk '{print $2}') != 'fedora' ]; then
    echo 'Debian'
else
    echo 'Fedora'
fi
COMMON_PKG_LIST="
    curl \
    wget \
    gnupg \
    jq \
    openssl \
    ca-certificates \
    python3-pip
"
UBUNTU_PKG_LIST="
    apt-transport-https \
    openssh-client 
"

#set Sudoers file
sudo sh -c 'echo "david  ALL=(ALL:ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/david'

## Map network share added into windows
sudo mkdir /mnt/z
sudo mount -t drvfs Z: /mnt/z

## persistent way
sudo sh -c 'echo "Z: /mnt/z drvfs defaults 0 0" >> /etc/fstab'

## Configure zsh
sudo apt install zsh
sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
#Set ZSH_THEME="powerlevel10k/powerlevel10k" in ~/.zshrc.

# Basic Packages
# --------------

sudo apt-get update -y
sudo apt-get install $UBUNTU_PKG_LIST
sudo apt-get install $COMMON_PKG_LIST


# Code Packages
# -------------
## Powershell Install
'''
## Fedora
curl https://packages.microsoft.com/config/rhel/8/prod.repo | sudo tee /etc/yum.repos.d/microsoft.repo
sudo dnf install --assumeyes powershell

sudo pwsh -Command "Install-Module -Name PSWSMan"
sudo pwsh -Command "Install-WSMan"
'''

###Debian
wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb"
sudo dpkg -i packages-microsoft-prod.deb
sudo apt-get update
sudo apt-get install -y powershell gss-ntlmssp
sudo pwsh -Command 'Install-Module -Name PSWSMan -Confirm:$false'
sudo pwsh -Command 'Install-WSMan'

## GO
sudo apt install golang -y
go version

# Python
python3 -V
pip3 -V

# Git
git version


# Kubernetes
# -------------

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh 

# Kustomize
wget https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv4.5.7/kustomize_v4.5.7_linux_amd64.tar.gz
tar -xvf kustomize_v4.5.7_linux_amd64.tar.gz
rm -f kustomize_v4.5.7_linux_amd64.tar.gz

# podman
apt install podman buildah skopeo

# buildah

sudo chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# OCP 
sudo wget https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/stable/openshift-client-linux.tar.gz
sudo tar -xvf openshift-client-linux.tar.gz
sudo rm -f openshift-client-linux.tar.gz



# terraform
sudo apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com focal main"
sudo apt install terraform -y
terraform -version

#packer
sudo apt -y install apt-transport-https ca-certificates curl software-properties-common mkisofs
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt update
sudo apt install packer
packer version

#vault
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vault

#calicoctl

curl -L https://github.com/projectcalico/calico/releases/download/v3.24.1/calicoctl-linux-amd64 -o calicoctl
sudo chmod +x calicoctl
calicoctl version

#aws cli 
sudo apt-get install awscli

#Azure cli
sudo apt-get update
sudo apt-get install ca-certificates curl apt-transport-https lsb-release gnupg
curl -sL https://packages.microsoft.com/keys/microsoft.asc |
    gpg --dearmor |
    sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" |
    sudo tee /etc/apt/sources.list.d/azure-cli.list
sudo apt-get update
sudo apt-get install azure-cli

var1='A'
var2='B'

my_function () {
  local var1='C'
  var2='D'
  echo "Inside function: var1: $var1, var2: $var2"
}

echo "Before executing function: var1: $var1, var2: $var2"

my_function

echo "After executing function: var1: $var1, var2: $var2"
