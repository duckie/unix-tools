# Common definitions for bash and zsh

pathadd() {
  while read dir; do 
    if [ -d "$dir" ] && [[ ":$PATH:" != *":$dir:"* ]]; then
      PATH="${PATH:+"$PATH:"}$dir"
    fi
  done< <(echo $1 | tr -s ":" "\n")
}

pathprepend() {
  while read dir; do 
    if [ -d "$dir" ] && [[ ":$PATH:" != *":$dir:"* ]]; then
      PATH="$dir:${PATH}"
    fi
  done< <(echo $1 | tr -s ":" "\n")
}

show_terminal_colors() {
  for i in {0..255}; do  printf "\x1b[38;5;${i}mcolor%-5i\x1b[0m" $i ; if ! (( ($i + 1 ) % 8 )); then echo ; fi ; done 
}

ssh() {
  if [[ -n "${TMUX_PANE:-}" && $# > 0 ]]; then
    local remote_name=$(command ssh -G "$@" |grep "^hostname"|awk '{print $2}'|awk -F. '{print $1}')
    tmux rename-window "$remote_name"
    command ssh "$@"
    tmux set-window-option automatic-rename "on" 1>/dev/null
  else
    command ssh "$@"
  fi
}

pipenv_activate() {
  . $(pipenv --venv)/bin/activate
}

cdgit() {
  cd "$(git rev-parse --show-toplevel)"
}

cdpipenv() {
  if [ -n "$VIRTUAL_ENV" ]; then
      if [ -f "$(dirname $VIRTUAL_ENV)/Pipfile" ]; then
        cd "$(dirname $VIRTUAL_ENV)"
      else
        echo "Cant find the Pipenv of current VIRTUAL_ENV"
        return 1
      fi
  else
    echo "Not in a virtual env"
    return 1
  fi
}

cdvenv() {
  if [ -n "$VIRTUAL_ENV" ]; then
    cd "$VIRTUAL_ENV"
  else
    echo "Not in a virtual env"
    return 1
  fi
}

resolveip() {
  python -c "import sys,socket; print(socket.gethostbyname(sys.argv[1]));" "$@"
}

sshuttle2() {
  # Extract hostname bash only, keep it here as a snippet
  #IFS="@" read -ra sshwords <<<"$1"
  #hostname="${sshwords[@]:(-1)}"
  if [[ "$(uname)" == "Linux" ]]; then
    sshuttle --method nft -r "$1" $(ssh -G "$1" | awk '$1 == "hostname" { print $2 }')
  else
    sshuttle -r "$1" $(ssh -G "$1" | awk '$1 == "hostname" { print $2 }')
  fi
}

list_all_from_cidr() {
  nmap -n -sL "$1"| awk '/Nmap scan report/{print $NF}'
}


# Default editor
export EDITOR=vim
if command -v nvim >/dev/null; then
  alias vim=nvim
  alias vimdiff='nvim -d'
  export EDITOR=nvim
fi

# custom helpers
TOOLS_BIN_PATH=$(dirname "${UNIX_TOOLS_CONFIG_PATH}")/bin
pathprepend ${TOOLS_BIN_PATH}

# Use home binary dir
if [ -d ${HOME}/bin ]; then
  pathprepend ${HOME}/bin
fi

# Probably deprecated
export GOPATH=${HOME}/projects/go
pathadd ${HOME}/gocode/bin:${HOME}/projects/go/bin

# Make gpg not complain
export GPG_TTY=$(tty)

# Aliases
if [[ "$(uname)" == "Darwin" ]]; then
  export CLICOLOR=1
  export LSCOLORS=gxBxhxDxfxhxhxhxhxcxcx
else
  alias ls='ls --color=auto'
fi

# Starting ssh-agent if configured to do so in main ~/.bashrc
SSH_ENV="$HOME/.ssh/environment"
function start_agent {
   echo "Initialising new SSH agent..."
   /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
   echo succeeded
   chmod 600 "${SSH_ENV}"
   . "${SSH_ENV}" > /dev/null
   #/usr/bin/ssh-add;
}
if [ 0 -lt "0${TOOLS_ENABLE_SSH_AGENT}" ]; then
  # Source SSH settings, if applicable
  if [ -f "${SSH_ENV}" ]; then
     . "${SSH_ENV}" > /dev/null
     #ps ${SSH_AGENT_PID} doesn't work under cywgin
     ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
         start_agent;
     }
  else
     start_agent;
  fi
fi
