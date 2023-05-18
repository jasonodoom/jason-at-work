KEYID="CD48C8F1AA7BB634"

export PROMPT_COMMAND="history -n; history -w; history -c; history -r"
export HISTCONTROL=ignoreboth:erasedups

# make the history larger
export HISTFILESIZE=4096
export HISTSIZE=4096

# Set the default editor
export EDITOR="subl -w"

# Nice colors for ls output
  export CLICOLOR=1
  export LSCOLORS="gxfxcxdxbxegedabagacad"
  eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  alias ll='ls -ltra --color=auto'
  alias tf='terraform'
  alias restart_gpg='gpgconf --kill gpg-agent'

# Add local bin directory to the path
export PATH=$PATH:$HOME/bin

# Nix
 if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
 fi
 # End Nix

#-------------------------------------------------------------------------------
SSH_ENV=$HOME/.ssh/environment

function start_ssh_agent {
    if [ ! -x "$(command -v ssh-agent)" ]; then
        return
    fi

    if [ ! -d "$(dirname $SSH_ENV)" ]; then
        mkdir -p $(dirname $SSH_ENV)
        chmod 0700 $(dirname $SSH_ENV)
    fi

    ssh-agent | sed 's/^echo/#echo/' > ${SSH_ENV}
    chmod 0600 ${SSH_ENV}
    . ${SSH_ENV} > /dev/null
    ssh-add
}

# Source SSH agent settings if it is already running, otherwise start
# up the agent proprely.
if [ -f "${SSH_ENV}" ]; then
     . ${SSH_ENV} > /dev/null
     # ps ${SSH_AGENT_PID} doesn't work under cywgin
     ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
         start_ssh_agent
     }
else
    case $UNAME in
      MINGW*)
        ;;
      *)
        start_ssh_agent
        ;;
    esac
fi

#-------------------------------------------------------------------------------
# Prompt
#-------------------------------------------------------------------------------
RED="\[\033[0;31m\]"
BROWN="\[\033[0;33m\]"
GREY="\[\033[0;97m\]"
GREEN="\[\033[0;32m\]"
BLUE="\[\033[0;34m\]"
PS_CLEAR="\[\033[0m\]"
SCREEN_ESC="\[\033k\033\134\]"

COLOR1="${BLUE}"
COLOR2="${BLUE}"
P="\$"

prompt_simple() {
    unset PROMPT_COMMAND
    PS1="\W\$(parse_git_branch) → "
    PS2="> "
}

prompt_compact() {
    unset PROMPT_COMMAND
    PS1="${COLOR1}${P}${PS_CLEAR} "
    PS2="> "
}

prompt_color() {
    PS1="${GREEN}\W\$(parse_git_branch) → ${GREY}"
    PS2="\[[33;1m\]continue \[[0m[1m\]> "
}

parse_git_branch() {
    [ -d .git ] || return 1
    git symbolic-ref HEAD 2> /dev/null | sed 's#\(.*\)\/\([^\/]*\)$# \2#'
}

# Set default prompt if interactive
test -n "$PS1" &&
prompt_color

export BASH_SILENCE_DEPRECATION_WARNING=1

export GPG_TTY=$(tty)
#export SSH_AUTH_SOCK=${HOME}/.gnupg/yubikey-agent.sock
#yubikey-agent -l ${HOME}/.gnupg/yubikey-agent.sock
export SSH_AUTH_SOCK=${HOME}/.gnupg/S.gpg-agent.ssh


### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/odoomj/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)
