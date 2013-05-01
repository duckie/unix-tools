#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias tconf='/home/canard/prog/treedconfig/py/tconf.py'

function shrunken_dir(){
	SEP="/"
	ESC_SEP="\\$SEP"
	HEADER_SIZE=5
	SIZE_MAX=$1
	current_disp=`pwd`
	seen_path_max_length=$((SIZE_MAX-HEADER_SIZE))
	current_seen_path=$(echo "$current_disp"|tr -s "$SEP")
	nb_dirs=0
	seen_path_length=$(expr length "$current_seen_path")
	while [ $seen_path_length -gt $seen_path_max_length ]; do
		current_seen_path=$(echo $current_seen_path|sed "s/^$ESC_SEP//"|grep -oE "$SEP.*")
		seen_path_length=$(expr length "$current_seen_path")
		nb_dirs=$((nb_dirs+1))
	done
	header="{$nb_dirs}"
	padding=""
	for i in $(seq $(expr length $header) $((SIZE_MAX-seen_path_length))); do
		padding="${padding}."
	done
	printf "${padding}${header}${current_seen_path}"
}

function display_fixed_size(){
	todisp=$1
  sizemax=$2
	prefix=$3
  postfix=$4
  result=${todisp}
  baselen=$(expr length ${todisp})
  baselen=$((baselen+1))
  for i in $(seq $baselen $sizemax); do
		result="${prefix}${result}${postfix}"
	done
	printf ${result}
}

#PS1="[\u@\h \W] `shrunken_dir 50`\$ "
PS1='[`display_fixed_size $? 3 "#"`]($(shrunken_dir 25))\[\033[01;31m\]$\[\033[00m\] '

if [ -f /etc/bash_completion ]; then
. /etc/bash_completion
fi

if [ ${TERM} = "xterm" ]; then
	export TERM="xterm-256color"
fi

