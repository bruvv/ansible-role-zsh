#!/usr/bin/env bash
set -eu

title() {
    local color='\033[1;37m'
    local nc='\033[0m'
    printf "${color}%s\n${nc}" "$1"
}

title "Install pip and Ansible"

case "$(uname -sr)" in

Darwin*)
    echo 'Running Mac OS stuff'
    if ! which -s brew; then
        # Install Homebrew
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        brew update
    fi
    brew_install=(ansible)
    for i in "${brew_install[@]}"; do
        printf "\nInstalling %s" "$i"
        if brew list "$i" &>/dev/null; then
            echo -e "\n${i} is already installed, updating package"
            brew upgrade "$i"
        else
            brew install "$i" && echo "$i is installed"
        fi
    done
    title "Download ansible-to-zsh to /tmp/zsh"
    git clone https://github.com/bruvv/ansible-role-zsh.git /tmp/zsh
    ansible-galaxy install bruvv.zsh_antigen --force

    title "Provision playbook for root"
    ansible-playbook -i "localhost," -c local -b /tmp/zsh/playbook.yml --extra-vars="zsh_user=$(whoami)" --ask-become-pass
    ;;

Linux*Microsoft*)
    echo 'Running WSL stuff' # Windows Subsystem for Linux
    ;;

Linux*)
    echo 'Running Linux stuff'
    sudo apt update
    sudo apt -y remove needrestart
    sudo apt install software-properties-common git -yqq
    sudo apt-add-repository --yes --update ppa:ansible/ansible
    sudo apt install ansible -yqq
    title "Download ansible-to-zsh to /tmp/zsh"
    git clone https://github.com/bruvv/ansible-role-zsh.git /tmp/zsh
    ansible-galaxy install bruvv.zsh_antigen

    title "Provision playbook for root"
    ansible-playbook -i "localhost," -c local -b /tmp/zsh/playbook.yml

    title "Provision playbook for $(whoami)"
    ansible-playbook -i "localhost," -c local -b /tmp/zsh/playbook.yml --extra-vars="zsh_user=$(whoami)"

    ;;

CYGWIN* | MINGW* | MINGW32* | MSYS*)
    echo 'Running MS Windows stuff'
    ;;

# Add here more strings to compare
# See correspondence table at the bottom of this answer

*)
    echo 'Failed to detect OS, exiting. Run only on Linux and Mac'

    ;;
esac

title "Finished! Please, restart your shell. And run p10k configure"
echo ""
