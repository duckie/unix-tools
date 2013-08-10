#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

if [ -d ${HOME}/bin ]; then
  export PATH=${HOME}/bin:$PATH
fi

alias ls='ls --color=auto'
alias tconf='/home/canard/prog/treedconfig/py/tconf.py'

#PS1="[\u@\h \W] `shrunken_dir 50`\$ "
pchar_blank=$(echo -e "\033[m")
pchar_folder_sep=$(echo -e "\033[31m")
PS1='`${HOME}/.tools/bin/cppprompt $? "$(pwd)" 38 --color "${pchar_blank}:${pchar_blank}:${pchar_blank}:${pchar_folder_sep}"`\[\033[01;31m\]\$\[\033[00m\] '
#PS1='\[\033[01;31m\]\$\[\033[00m\] '1
if [ -f /etc/bash_completion ]; then
. /etc/bash_completion
fi

if [ ${TERM} = "xterm" ]; then
	export TERM="xterm-256color"
fi

