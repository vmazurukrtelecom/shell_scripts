#!/usr/bin/env bash
## user without root:
## OS OracleLinux 9.5 tested
## ver20250107
#####
## place this file "general_ol9.sh" at the location of the root Vagrantfile for your project
## add to Vagrantfile:
## config.vm.provision "shell", path: "general_ol9.sh", privileged: false
## supported also refs to https, i.e.
## config.vm.provision "shell", path: "https://raw.githubusercontent.com/vmazurukrtelecom/shell_scripts/refs/heads/main/general_ol9.sh"
#####
## START
start=`date +%s`
echo "script name general_ol9.sh"
echo "start time:"
date
## SWAP:
# fallocate -l 16G /swapfile
# chmod 600 /swapfile
# mkswap /swapfile
# swapon /swapfile
# findmnt --verify --verbose
swapon --show
sysctl -a | grep swappin
# cp /etc/fstab /etc/fstab.bak
# echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
cat /etc/fstab
cat /proc/sys/vm/vfs_cache_pressure
## ADD HISTORY:
grep -q 'HISTTIMEFORMAT' /etc/bashrc || printf 'export HISTTIMEFORMAT="%%y-%%m-%%d_%%H:%%M:%%S "\nexport HISTSIZE=100000\nexport HISTFILESIZE=1000000\n' | sudo tee -a /etc/bashrc
## add /usr/local/bin to the PATH globall
echo 'export PATH=$PATH:/usr/local/bin' >> /etc/profile
## UPDATE:
sudo dnf -y update
sudo dnf -y install oracle-epel-release-el9
sudo dnf -y upgrade
## OPTIONAL:
sudo dnf -y install PackageKit-command-not-found bash-completion mc htop git curl screen net-tools tree nano #tcpdump iptraf-ng iftop ncdu
# sudo dnf config-manager --set-enabled ol9_codeready_builder
# sudo dnf install glibc-all-langpacks –y # langpacks-en
#sudo dnf -y install mc unzip zstd pv neovim htop nethogs nload inxi lsof socat ncdu tmux
#sudo dnf -y install bzip2-devel libffi-devel xz-devel xz-libs ncurses-devel sqlite-devel
#sudo dnf -y install python3.11 python3.11-devel python3.11-test python3.11-idle python3.11-wheel
#sudo dnf -y install python3.12 python3.12-devel python3.12-test python3.12-idle python3.12-wheel
## set timezone
sudo timedatectl set-timezone Europe/Kyiv
## disable ipv6 permanently:
echo "net.ipv6.conf.all.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf
echo "net.ipv6.conf.lo.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf
echo "net.ipv6.conf.tun0.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf
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
## disable DNS via DHCP (for docker image download)
cat /etc/resolv.conf
# sudo nmcli conn modify "Wired connection 1" ipv4.ignore-auto-dns yes
# sudo nmcli conn modify "Wired connection 1" ipv4.dns  "8.8.8.8,1.1.1.1"
# sudo nmcli conn modify "System eth1" ipv4.ignore-auto-dns yes
# sudo nmcli conn modify "System eth1" ipv4.dns  "8.8.8.8,1.1.1.1"
# sudo systemctl restart NetworkManager
# sleep 5
# cat /etc/resolv.conf
# check VBoxClient installed (required gui)
# VBoxClient --version
## SELINUX:
getenforce
# setenforce 0
# sudo sed -i 's/^SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config
## FIREWALL:
firewall-cmd --state
# firewall-cmd --add-service=https --permanent
# firewall-cmd --permanent --zone=public --add-port=8080/tcp
# firewall-cmd --list-all
# firewall-cmd --reload
##
# dnf whatprovides ldapsearch
# dnf install openldap-clients
## CHECK IF NEEDS REBOOT
needs-restarting -r
#
echo "finish time:"
date
## runtime
end=`date +%s`
runtime=$((end-start))
echo "runtime=$runtime seconds"
## REF runtime: https://unix.stackexchange.com/a/52347
##
## ADDIT:
## REBOOT via Vagrantfile:
## add to Vagrantfile:
# config.vm.provision "shell", reboot: true, inline: <<-SHELL
# echo "rebooting!"
# SHELL
## END
