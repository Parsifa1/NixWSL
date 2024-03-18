set -U fish_greeting

clear

dbus-launch true
set_panetitle

export FZF_DEFAULT_COMMAND="fd -H -I --exclude={.git,.idea,.vscode,.sass-cache,node_modules,build,.vscode-server,.virtualenvs} --type f"
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --color=bg+:,bg:,gutter:-1,spinner:#f5e0dc,hl:#f38ba8 --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"
export EDITOR="nvim"
export DISPLAY=":0"
export WAYLAND_DISPLAY=wayland-0

if test -d "/mnt/c/Windows/System32/"
    export PATH="$PATH:/mnt/c/Windows/System32/"
end
