#!/usr/bin/env bash
set -eu

title() {
    local color='\033[1;37m'
    local nc='\033[0m'
    printf "\n${color}$1${nc}\n"
}

title "Install pip and Ansible"

case "$(uname -sr)" in

Darwin*)
    echo 'Running Mac OS stuff'
    which -s brew
    if [[ $? != 0 ]]; then
        # Install Homebrew
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        brew update
    fi
    brew_install() {
        printf "\nInstalling %s" "$1"
        if brew list "$1" &>/dev/null; then
            echo "${1} is already installed, updating package"
            brew upgrade "$1"
        else
            brew install "$1" && echo "$1 is installed"
        fi
    }
    brew_install "ansible"
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

title "Download ansible-to-zsh to /tmp/zsh"
git clone https://github.com/bruvv/ansible-role-zsh.git /tmp/zsh

title "Provision playbook for root"
ansible-playbook -i "localhost," -c local -b /tmp/zsh/playbook.yml

title "Provision playbook for $(whoami)"
ansible-playbook -i "localhost," -c local -b /tmp/zsh/playbook.yml --extra-vars="zsh_user=$(whoami)"

title "Finished! Please, restart your shell."
echo ""
