# Tested on Ubuntu 22.04, macOS 13.0.1

## Zero-knowledge install

If you using Ubuntu or Debian and not familiar with Ansible, you can just execute [install.sh](install.sh) on target machine:

```bash
curl https://raw.githubusercontent.com/bruvv/ansible-role-zsh/main/install.sh | bash
```

Then [configure terminal application](#configure-terminal-application).

## Includes

- zsh
- [antigen](https://github.com/zsh-users/antigen)
- [powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh)
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
- [unixorn/autoupdate-antigen.zshplugin](https://github.com/unixorn/autoupdate-antigen.zshplugin)
- [ytet5uy4/fzf-widgets](https://github.com/ytet5uy4/fzf-widgets)
- [urbainvaes/fzf-marks](https://github.com/popstas/urbainvaes/fzf-marks)

## Features

- customize powerlevel10k theme prompt segments and colors
- add custom prompt elements from yml
- custom zsh config with `~/.zshrc.local` or `/etc/zshrc.local`
- load `/etc/profile.d` scripts
- install only plugins that useful for your machine. For example, plugin `docker` will not install if you have not Docker

## 1.5 mins demo

![1.5 mins demo](https://github.com/popstas/popstas.github.io/blob/master/images/2017-03/ansible-role-zsh-demo.gif?raw=true)

## Color schemes

![colors demo](https://github.com/popstas/popstas.github.io/blob/master/images/2017-03/ansible-role-zsh-colors.gif?raw=true)

## Demo install in Vagrant

You can test work of role before install in real machine.
Just execute `vagrant up`, then `vagrant ssh` for enter in virtual machine.

Note: you cannot install vagrant on VPS like Digital Ocean or in Docker. Use local machine for it.
[Download](https://www.vagrantup.com/downloads.html) and install vagrant for your operating system.

## Install for real machine

Zero-knowledge install: see [above](#zero-knowledge-install).

## Multiuser shared install

If you have 10+ users on host, probably you don't want manage tens of configurations and thousands of files.

In this case you can deploy single zsh config and include it to all users.

It causes some limitations:

- Users have read only access to zsh config
- Users cannot disable global enabled bundles
- Possible bugs such cache write permission denied
- Possible bugs with oh-my-zsh themes

For install shared configuration you should set `zsh_shared: yes`.
Configuration will install to `/usr/share/zsh-config`, then you just can include to user config:

```bash
source /usr/share/zsh-config/.zshrc
```

You can still provision custom configs for several users.

## Configure

You should not edit `~/.zshrc`!
Add your custom config to `~/.zshrc.local` (per user) or `/etc/zshrc.local` (global).
`.zshrc.local` will never touched by ansible.

### Configure terminal application

1. Download [powerline fonts](https://github.com/powerline/fonts), install font that you prefer.
   You can see screenshots [here](https://github.com/powerline/fonts/blob/master/samples/All.md).

2. Set color scheme.

    Personaly, I prefer Solarized Dark color sceme, Droid Sans Mono for Powerline in iTerm and DejaVu Sans Mono in Putty.

#### iTerm

Profiles - Text - Change Font - select font "for Powerline"

Profiles - Colors - Color Presets... - select Solarized Dark

#### Putty

Settings - Window - Appearance - Font settings

You can download [Solarized Dark for Putty](https://github.com/altercation/solarized/tree/master/putty-colors-solarized).

#### Gnome Terminal

gnome-terminal have built-in Solarized Dark, note that you should select both background color scheme and palette scheme.

### Hotkeys

You can view hotkeys in [roles/zsh-install/defaults/main.yml](roles/zsh-install/defaults/main.yml), `zsh_hotkeys`.

Sample hotkey definitions:

```yaml
- { hotkey: "^r", action: "fzf-history" }
# with dependency of bundle
- {
    hotkey: "`",
    action: autosuggest-accept,
    bundle: zsh-users/zsh-autosuggestions,
  }
```

Useful to set `autosuggest-accept` to <kbd>`</kbd> hotkey, but it conflicts with Midnight Commander (break Ctrl+O subshell).

You can add your custom hotkeys without replace default hotkeys with `zsh_hotkeys_extras` variable:

```yaml
zsh_hotkeys_extras:
  - { hotkey: "^[^[[D", action: backward-word } # alt+left
  - { hotkey: "^[^[[C", action: forward-word } # alt+right
  # Example <Ctrl+.><Ctrl+,> inserts 2nd argument from end of prev. cmd
  - { hotkey: "^[,", action: copy-earlier-word } # ctrl+,
```

### Aliases

You can use aliases for your command with easy deploy.
Aliases config mostly same as hotkeys config:

```yaml
zsh_aliases:
  - { alias: 'dfh', action: 'df -h | grep -v docker' }
# with dependency of bundle and without replace default asiases
- zsh_aliases_extra
  - { alias: 'dfh', action: 'df -h | grep -v docker', bundle: }
```

#### Default hotkeys from plugins

- <kbd>&rarr;</kbd> - accept autosuggestion
- <kbd>Ctrl+Z</kbd> - move current application to background, press again for return to foreground
- <kbd>Ctrl+G</kbd> - jump to bookmarked directory. Use `mark` in directory for add to bookmarks
- <kbd>Ctrl+R</kbd> - show command history
- <kbd>Ctrl+@</kbd> - show all fzf-widgets
- <kbd>Ctrl+@,C</kbd> - fzf-change-dir, press fast!
- <kbd>Ctrl+\\</kbd> - fzf-change-recent-dir
- <kbd>Ctrl+@,G</kbd> - fzf-change-repository
- <kbd>Ctrl+@,F</kbd> - fzf-edit-files
- <kbd>Ctrl+@,.</kbd> - fzf-edit-dotfiles
- <kbd>Ctrl+@,S</kbd> - fzf-exec-ssh (using your ~/.ssh/config)
- <kbd>Ctrl+@,G,A</kbd> - fzf-git-add-file
- <kbd>Ctrl+@,G,B</kbd> - fzf-git-checkout-branch
- <kbd>Ctrl+@,G,D</kbd> - fzf-git-delete-branches

## Configure bundles

You can check default bundles in [roles/zsh-install/defaults/main.yml](roles/zsh-install/defaults/main.yml#L37).
If you like default bundles, but you want to add your bundles, use `zsh_antigen_bundles_extras` variable (see example playbook above).
If you want to remove some default bundles, you should use `zsh_antigen_bundles` variable.

Format of list matches [antigen](https://github.com/zsh-users/antigen#antigen-bundle). All bellow variants valid:

```yaml
- docker # oh-my-zsh plugin
- zsh-users/zsh-autosuggestions # plugin from github
- zsh-users/zsh-autosuggestions@v0.3.3 # plugin from github with fixed version
- ~/projects/zsh/my-plugin --no-local-clone # plugin from local directory
```

Note that bundles can use conditions for load. There are two types of conditions:

1. Command conditions. Just add `command` to bundle:

    ```yaml
    - { name: docker, command: docker }
    - name: docker-compose
      command: docker-compose
    ```

    Bundles `docker` and `docker-compose` will be added to config only if commands exists on target system.

2. When conditions. You can define any ansible conditions as you define in `when` in tasks:

    ```yaml
    # load only for zsh >= 4.3.17
    - name: zsh-users/zsh-syntax-highlighting
      when: "{{ zsh_version is version_compare('4.3.17', '>=') }}"
    # load only for macOS
    - { name: brew, when: "{{ ansible_os_family != 'Darwin' }}" }
    ```

    Note: you should wrap condition in `"{{ }}"`

## Custom config

You can add any code in variable `zsh_custom_before`, `zsh_custom_after`.

- zsh_custom_before - before include antigen.zsh
- zsh_custom_after - before include ~/.zshrc.local

## Run locally

`ansible-playbook -i "localhost," -c local -b playbook-local.yml --extra-vars="zsh_user=$(whoami)" --ask-become-pass`
