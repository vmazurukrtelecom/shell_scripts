#!/usr/bin/env bash
## user without root:
## OS OracleLinux 9.5 tested
## ver202501
#####
## place this file "general_ol.sh" at the location of the root Vagrantfile for your project
## add to Vagrantfile:
## config.vm.provision "shell", path: "general_ol.sh", privileged: false
## supported also refs to https, i.e.
## config.vm.provision "shell", path: "https://raw.githubusercontent.com/vmazurukrtelecom/shell_scripts/refs/heads/main/general_ol.sh"
#####
echo "script name: general_ol.sh"
# echo 'current script text:'
# cat $0
## START
start=$(date +%s)
echo "start time:"
date
## set exit if error (return <>0):
# set -e
##
RHEL_VER=$(rpm -E '%{rhel}')
echo "RHEL_VER=$RHEL_VER"
## SWAP:
# fallocate -l 16G /swapfile
# chmod 600 /swapfile
# mkswap /swapfile
# swapon /swapfile
# findmnt --verify --verbose
# swapon --show
# sysctl -a | grep swappin
# cp /etc/fstab /etc/fstab.bak
# echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
# cat /etc/fstab
# cat /proc/sys/vm/vfs_cache_pressure
## ADD HISTORY:
grep -q 'HISTTIMEFORMAT' /etc/bashrc || printf 'export HISTTIMEFORMAT="%%y-%%m-%%d_%%H:%%M:%%S "\nexport HISTSIZE=100000\nexport HISTFILESIZE=1000000\n' | sudo tee -a /etc/bashrc
## add /usr/local/bin to the PATH globall
echo 'add /usr/local/bin to the PATH globally'
grep -q 'PATH:/usr/local/bin' /etc/profile || echo 'export PATH=$PATH:/usr/local/bin' | sudo tee -a /etc/profile
# tail -n 1 /etc/profile
# TODO: To ensure that all binaries is accessible via the sudo command Add the following line to the sudoers file:
# Defaults    secure_path = /sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin
## UPDATE:
sudo dnf -y update
sudo dnf -y install oracle-epel-release-el"$RHEL_VER"
sudo dnf -y upgrade
## OPTIONAL:
# sudo dnf makecache  
sudo dnf -y install PackageKit-command-not-found bash-completion mc htop git curl screen net-tools tree nano bind-utils #python3 python3-pip #tcpdump iptraf-ng iftop ncdu
# sudo dnf config-manager --set-enabled ol9_codeready_builder
# sudo dnf group install "Development Tools"
# sudo dnf install glibc-all-langpacks –y # langpacks-en
# sudo dnf -y install mc unzip zstd pv neovim htop nethogs nload inxi lsof socat ncdu tmux
# sudo dnf -y install bzip2-devel libffi-devel xz-devel xz-libs ncurses-devel sqlite-devel
#
# sudo dnf -y install python3.11 python3.11-devel python3.11-test python3.11-idle python3.11-wheel
# sudo dnf -y install python3.12 python3.12-devel python3.12-setuptools python3.12-six python3.12-wheel python3.12-pip
echo 'system python version /usr/libexec/platform-python -V'
/usr/libexec/platform-python -V
# sudo python3 -m pip install --upgrade pip
alternatives --list
python3 -V
# pip3 -V
# alternatives --set /usr/bin/python python /usr/bin/python3.12 1
# alternatives --set python3 /usr/bin/python3.12
# 
#
# sudo dnf -y groupinstall "Development Tools"
## set timezone
sudo timedatectl set-timezone Europe/Kyiv
## disable ipv6 permanently:
grep -q 'net.ipv6.conf.all.disable_ipv6 = 1' /etc/sysctl.conf || echo "net.ipv6.conf.all.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf
grep -q 'net.ipv6.conf.default.disable_ipv6 = 1' /etc/sysctl.conf || echo "net.ipv6.conf.default.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf
grep -q 'net.ipv6.conf.lo.disable_ipv6 = 1' /etc/sysctl.conf || echo "net.ipv6.conf.lo.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf
grep -q 'net.ipv6.conf.tun0.disable_ipv6 = 1' /etc/sysctl.conf || echo "net.ipv6.conf.tun0.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
ip a
## disable ipv6 
sudo systemctl restart NetworkManager
sudo nmcli con show
# latest ver of OL9 network interface named as: "Wired connection 1" (NAT) + "System eth1"
# sudo nmcli conn modify "Wired connection 1" ipv6.method "disabled"
# sudo nmcli connection up "Wired connection 1"
# sudo nmcli conn modify "System eth1" ipv6.method "disabled"
# sudo nmcli connection up "System eth1"
# sudo nmcli conn modify "System eth0" ipv6.method "disabled"
# sudo nmcli connection up "System eth0"
## disable DNS via DHCP (for docker image download)
# cat /etc/resolv.conf
## disable DNS via DHCP (for docker image download - failed via ipv6)
# second IF = System eth1
# sudo nmcli conn modify "System eth1" ipv4.ignore-auto-dns yes
# sudo nmcli conn modify "System eth1" ipv4.dns  "8.8.8.8,1.1.1.1"
##
# Oracle Linux 8
if [[ "$RHEL_VER" == "8" ]]; then
  echo "Oracle Linux 8 detected. Applying OL8-specific configurations."
  sudo nmcli conn modify "System eth0" ipv4.ignore-auto-dns yes
  sudo nmcli conn modify "System eth0" ipv4.dns  "8.8.8.8,1.1.1.1"
  sudo nmcli connection up "System eth0"
# Oracle Linux 9
elif [[ "$RHEL_VER" == "9" ]]; then
  echo "Oracle Linux 9 detected. Applying OL9-specific configurations."
  sudo nmcli conn modify "Wired connection 1" ipv4.ignore-auto-dns yes
  sudo nmcli conn modify "Wired connection 1" ipv4.dns  "8.8.8.8,1.1.1.1"
  sudo nmcli connection up "Wired connection 1"
  sudo nmcli conn modify "eth0" ipv4.ignore-auto-dns yes
  sudo nmcli conn modify "eth0" ipv4.dns  "8.8.8.8,1.1.1.1"
  sudo nmcli connection up "eth0"
else
  echo "Other Oracle Linux version. RHEL_VER=$RHEL_VER"
fi
sudo systemctl restart NetworkManager
# sleep 5
cat /etc/resolv.conf
# check VBoxClient installed (required gui)
# VBoxClient --version
## SELINUX:
getenforce
# sudo setenforce 0 # works only current session
# grep -q 'SELINUX=permissive' /etc/selinux/config || sudo sed -i 's/^SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config
sudo sed -i -r '/^SELINUX=(permissive|enforcing)/s/SELINUX=(permissive|enforcing)/SELINUX=disabled/' /etc/selinux/config
# getenforce
## FIREWALL:
firewall-cmd --state
# firewall-cmd --add-service=https --permanent
# firewall-cmd --permanent --zone=public --add-port=8080/tcp
# firewall-cmd --list-all
# firewall-cmd --reload
##
sudo dnf clean all
## 
# dnf whatprovides ldapsearch
# dnf install openldap-clients
## ...
## Docker:
## ADDIT REFs:
## https://badtry.net/docker-tutorial-dlia-novichkov-rassmatrivaiem-docker-tak-iesli-by-on-byl-ighrovoi-pristavkoi/
## https://chrisjhart.com/TLDR-Docker-Ubuntu-2204/
## https://docs.docker.com/engine/install/centos/
# sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
# sudo dnf -y update
# sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
# sudo dnf install -y docker-ce docker-ce-cli containerd.io
# dnf list docker-ce --showduplicates
## sudo usermod -aG docker $USER
# usermod -aG docker vagrant # need to be specified via script running as root
# newgrp docker # to activate the changes to groups (without sudo !!!) - does not work
# newgrp - docker # to activate the changes to groups (without sudo !!!) - does not work
## sudo groups $USER
# sudo groups vagrant
# id
# sudo docker --version
# sudo systemctl start docker.service
# sudo systemctl enable docker.service
# sudo systemctl enable containerd.service
# sudo systemctl status docker.service
# docker --version
# docker run hello-world
# docker ps -a
# docker stop $(docker ps -a -q)   # stop all containers
# docker rm $(docker ps -a -q)     # remove all containers
# docker image list
# docker image inspect hello-world:latest
# docker image rm hello-world:latest
##
## CHECK IF NEEDS REBOOT
needs-restarting -r
#
df -h
free -h
echo "finish time:"
date
## runtime
end=$(date +%s)
runtime=$((end-start))
minutes=$((runtime / 60))
seconds=$((runtime % 60))
echo "runtime=$minutes minutes and $seconds seconds"
## REF runtime: https://unix.stackexchange.com/a/52347
##
## ADDIT:
## REBOOT via Vagrantfile:
## add to Vagrantfile:
# config.vm.provision "shell", reboot: true, inline: <<-SHELL
# echo "rebooting!"
# SHELL
## END
