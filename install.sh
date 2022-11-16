#!/usr/bin/env bash
set -eu

title() {
    local color='\033[1;37m'
    local nc='\033[0m'
    printf "\n${color}$1${nc}\n"
}

title "Install pip and Ansible"
sudo apt update
sudo apt install python3-pip -y
sudo pip3 install ansible

# title "Install viasite-ansible.zsh"
# ansible-galaxy install viasite-ansible.zsh --force

title "Download ansible-to-zsh to /tmp/zsh.yml"
git clone https://github.com/bruvv/ansible-role-zsh.git /tmp/zsh

title "Provision playbook for root"
ansible-playbook -i "localhost," -c local -b /tmp/zsh/zsh.yml

title "Provision playbook for $(whoami)"
ansible-playbook -i "localhost," -c local -b /tmp/zsh/zsh.yml --extra-vars="zsh_user=$(whoami)"

title "Finished! Please, restart your shell."
echo ""
