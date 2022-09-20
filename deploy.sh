'''
Packages list:
    - Code 
        Python 3.x - +
        Python PIP - +
        jq - 
        Powershell - +
        Go - +
        Git - +
    - Kubernetes
        kubectl - +
        calicoctl - +
        Helm - +
        Kustomize - +
        etcd client
        Openshift - +
        Argo Cli
        podman - +
        buildah - +
        skopeo - +
    - S3 Management
        Minio Client
    - Cloud Management
        AWS cli - +
        Azure cli - +
    - IaC
        Terraform - +
        Packer - +
        Calm-DSL
    - Cli
        Vault-Cli - +

# Configure WSL
# -------------
##list wsl containes
wsl -l -v

##set wsl version 2 by default
wsl --set-default-version 2

##change wsl version for an existing wsl deployment 
wsl --set-version <wsl image name> 2

'''
set -a # automatically export all variables
source .env
set +a

# Set values
OS_FAMILY=$(cat /etc/os-release | grep ID_LIKE | sed 's/=/ /g' | sed 's/"//g' | awk '{print $2}')
OS_VERSION=$(cat /etc/os-release | grep VERSION | sed 's/=/ /g' | sed 's/"//g' | awk '{print $2}')
if [ $(cat /etc/os-release | grep ID_LIKE | sed 's/=/ /g' | sed 's/"//g' | awk '{print $2}') != 'fedora' ]; then
    echo 'Debian'
else
    echo 'Fedora'
fi

# Config Sudoers
echo "$USER  ALL=(ALL:ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$USER

# Init updates
sudo apt update -y && sudo apt upgrade -y

# Add shared folder
{
sudo mkdir /mnt/z
sudo mount -t drvfs Z: /mnt/z
sudo sh -c 'echo "Z: /mnt/z drvfs defaults 0 0" >> /etc/fstab'

# Add repos
## Powershell
wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb"
sudo dpkg -i packages-microsoft-prod.deb
## Packer, Terraform, Vault
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
## Azure cli
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null

# Install Packages
COMMON_PKG_LIST="
    zsh \
    tree \
    curl \
    wget \
    gnupg \
    lsb-release \
    jq \
    openssl \
    ca-certificates \
    software-properties-common \
    mkisofs \
    apt-transport-https \
    openssh-client  \
    python3-pip \
    git \
    powershell \
    gss-ntlmssp \
    golang \
    podman \
    buildah \
    skopeo \
    terraform \
    packer \
    vault \
    awscli \
    azure-cli
"
sudo apt update -y
sudo apt install -y $COMMON_PKG_LIST

# Configure Powershell
sudo pwsh -Command 'Install-Module -Name PSWSMan -Confirm:$false'
sudo pwsh -Command 'Install-WSMan'

# Configure Python

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

# calicoctl
curl -L https://github.com/projectcalico/calico/releases/download/v3.24.1/calicoctl-linux-amd64 -o calicoctl

# OCP 
sudo wget https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/stable/openshift-client-linux.tar.gz
sudo tar -xvf openshift-client-linux.tar.gz
sudo rm -f openshift-client-linux.tar.gz README.md

# Configure binaries
sudo chmod +x kubectl kustomize calicoctl oc
sudo mv kubectl kustomize calicoctl oc /usr/local/bin


# Configure zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
#Set ZSH_THEME="powerlevel10k/powerlevel10k" in ~/.zshrc.

# List Versions
## Python
python3 -V
pip3 -V
## Powershell
pwsh -v
## Git
git version
## Golang
go version
## Terraform
terraform version
## Packer 
packer version
## Vault
vault version
## kubectl
kubectl version
kustomize version
oc version
podman version
buildah version
skopeo -v
helm version
calicoctl version
# Clouds
az -v
}