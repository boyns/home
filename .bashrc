# -*- sh -*-

inside_bashrc=1

# bash is interactive if $- contains `i'.
interactive=0
case $- in
*i*)
    interactive=1
    ;;
esac

if [ "$PS1" = "" -a -f $HOME/.bash_profile ]
then
    . $HOME/.bash_profile
fi

WHOAMI=$(whoami)

# -------------------------------------------------------------------------------
# prompt

if [ "$EMACS" = "t" ]
then
    PS1='\h\$'
elif [ -n "$SSH_CLIENT" ]
then
    PS1='\h:\w [\!]+\$'
else
    PS1='\h:\w [\!]-\$'
fi
case $TERM in
eterm)
    prompt_style=reverse
    ;;
xterm*|screen*)
#    if xterm -h 2>&1 | grep -e '-/+cm' > /dev/null # look for the cm option
#    then
#	prompt_style=color
#    else
#	prompt_style=reverse
#    fi
    prompt_style=color
    ;;
rxvt)
    prompt_style=color
    ;;
linux|pc*)
    prompt_style=color
    ;;
sun|vt100|vt102|vt220|ansii|dtterm)
    prompt_style=reverse
    ;;
esac

case $prompt_style in
color)
    if [ $WHOAMI = "root" ];
    then
        color_on='\e[01;41m'
    else
        color_on='\e[01;44m'
    fi
    color_off='\e[0m'
    ;;
reverse)
    color_on='\e[7m'
    color_off='\e[0m'
    ;;
esac

PS1='\['${color_on}'\]'${PS1}'\['${color_off}'\] '
unset prompt_style color_on color_off

# -------------------------------------------------------------------------------

if [ -z "$HOSTNAME" ]
then
    export HOSTNAME=`hostname`
fi

auto_resume=
HISTCONTROL=ignoredups
HISTSIZE=500
HISTFILE=""
#FIGNORE=".o:~"

set -o noclobber
set -o notify

shopt -s checkwinsize
shopt -u cdspell hostcomplete sourcepath

# -------------------------------------------------------------------------------
# functions

function xterm-title ()
{
    if [ -n "$1" ]
    then
        builtin echo -e -n "\033]2;$1\007"
    else
        builtin echo -e -n "\033]2;${WHOAMI}@${HOSTNAME}:${PWD}\007"
    fi	
}

function xterm-icon ()
{
    local base
    if [ -n "$1" ]
    then
        builtin echo -e -n "\033]1;$1\007"
    else
        #builtin echo -e -n "\033]1;${WHOAMI}@${HOSTNAME}\007"
        builtin echo -e -n "\033]1;${HOSTNAME}\007"
    fi	
}

function cd ()
{
    if [ "$1" = "" ]
    then
        builtin cd
    else
        builtin cd "$@"
    fi

    case $TERM in
    xterm*|rxvt*)
        xterm-title
        xterm-icon
	;;
    esac
}

function Man ()
{
    eval nroff -man "$@" | ${PAGER}
}

function ftp ()
{
    local machines m
    local ftper

    ftper=`type -path ncftp`
    ftper=${ftper:=ftp}
    
    if [ $# -eq 0 ]
    then
        machines=$(grep ^machine $HOME/.netrc | awk '{ print $2 }' | sort);
        select m in $machines
        do
            if [ $TERM = "xterm" ]
            then
		xterm-title "ftp: $m"
       	    fi
            command $ftper $m
        done
    else
        if [ $TERM = "xterm" ]
        then
	    xterm-title "ftp: $@"
       	fi
        command $ftper "$@";
    fi

    if [ $TERM = "xterm" ]
    then
        xterm-title
        xterm-icon
    fi
}

function setenv ()
{
    if [ $# -ne 2 ]
    then
        echo "setenv: Too few arguments"
    else
        export $1="$2"
    fi
}

function pskill ()
{
    local pid
    local yorn
    pid=$(ps -ax | grep $1 | grep -v grep | awk '{ print $1 }')
    echo -n "Kill $1 (process $pid)? [y/n] "
    read yorn
    if test "$yorn" = "y"
    then
        kill -9 $pid;
        echo "$1 ($pid) slaughtered.";
    else
        echo "Not killed.";
    fi
}

function zap ()
{
    local found=$(type -path zap >/dev/null)
    if [ -n "$found" ]
    then
	command zap $@
    else
	local ask=true
	local listonly=false
	local prog=
	local signal="-15"

	for ARG
	do
	    case "$ARG" in
	    -[0-9]|-[0-9][0-9])
	        signal=$ARG
		;;
	    -y)
		ask=false
		;;
	    -l)
		listonly=true
		;;
	    -*)
		echo zap: illegal option $ARG
		return 1
		;;
	    *)
	    	prog=$ARG
		;;
	    esac
	done
	
	if type -path pidof >/dev/null
	then
	    # linux
	    pidlist=$(pidof -x $prog)
	    [ "$pidlist" ] && ps auwx $pidlist
	elif [ -e /etc/.name_service_door ]
	then 
	    pidlist=$(ps -e | grep $prog | awk '{print $1}')
	    [ "$pidlist" ] && ps -p "$pidlist"
	else
	    pidlist=$(ps -ax | grep $prog | grep -v grep | tee /dev/tty | awk '{print $1}')
	fi

	if [ -z "$pidlist" ]
	then
	    echo "$prog not running"
	    return 1 
	fi

	if $listonly
	then
	   return
	fi

	if $ask
	then
	    local yorn
	    local pid
	    for pid in $pidlist
	    do
	        echo -n "Kill process $pid with $signal? [n] "
	        read yorn
		case $yorn in
		y|Y)
		    kill $signal $pid
		    ;;
		q|Q|x|X)
		    return
		    ;;
		esac
	    done
	else
	    kill $signal $pidlist
	    return
	fi
    fi
    return 0
}


function rpg ()
{
    local list=`egrep -i "/[^/]*$1[^/]*$" /usr/local/sounds/rplay.conf`
    echo $list
    if [ -n "$list" ]
    then
	rplay $list
    fi	
}

function startx ()
{
    if [ $# -eq 0 ]
    then
	command ssh-agent startx
    else
	command ssh-agent startx -- -bpp $1
    fi
}

function dotcopy ()
{
    scp -vr .bashrc .bash_profile .inputrc .xinitrc .Xdefaults .ctwmrc .fvwm2rc .lftprc .exrc .indent.pro pixmaps backgrounds $1:
}

# ------------------------------------------------------------------------------
# aliases

# use color ls if dircolors exists
#if type -path dircolors > /dev/null
#then
    eval `dircolors`
    alias ls='command ls -Fsa --color=auto';
    alias dir='command ls -lFa --color=auto'
    alias ll='command ls -lFa --color=auto'
#else
#    alias ls='command ls -Fsa'
#    alias dir='command ls -lFa'
#    alias ll='command ls -lFa'
#fi

alias unsetenv=unset
alias which='type -all'
alias lss=less
alias les=less
alias lesss=less
alias sc='. ~/.bashrc'
alias sl='. ~/.bash_profile'
alias h='history | $PAGER' 
alias abort='kill -9 %%'
#alias c='echo "[H[2J"'
alias whois='whois -h whois'
alias openwin='/usr/openwin/bin/openwin'
alias x='TERM=xterm; eval `resize`'
#alias meta='telnet xpilot.cs.uit.no 4400'
#alias meta2='telnet xpilot.mc.bio.uva.nl 4400'
#alias newsdude='ssh -l news newshub'
#alias conf='./configure --prefix=/usr/local'
#alias tape0='TAPE=/dev/ndat0'
#alias tape1='TAPE=/dev/ndat1'
#alias prep='ftp prep.ai.mit.edu'
alias byte-compile='xemacs -batch -q -no-site-file -f batch-byte-compile'
alias byte-compile-xemacs='xemacs -batch -q -no-site-file -f batch-byte-compile'
alias byte-compile-emacs='emacs -batch -q -no-site-file -f batch-byte-compile'
#alias wabi='/opt/SUNWwabi/bin/wabi'
#alias weather='lynx http://iwin.nws.noaa.gov/iwin/ca/hourly.html'
#alias bindver='nslookup -class=chaos -type=txt version.bind.'
#alias nic='command whois -h whois.internic.net'
#alias arin='command whois -h whois.arin.net'
#alias hangup='zap -y pppd'

## Quick cd aliases
#alias src='cd /usr/local/src/'
#alias util='cd /usr/local/src/util'
#alias gnu='cd /usr/local/src/gnu'
#alias games='cd /usr/local/src/games'
#alias news='cd /usr/local/src/news'
#alias rp='cd ~/src/rplay'
#alias rpd='cd ~/src/rplay/rplayd'
#alias elisp='cd /usr/local/src/elisp'
alias common='cd /local/mnt/workspace/mboyns/bds/main/development/common'
alias qiscommon='cd /local/mnt/workspace/mboyns/shared/main/development/qiscommon'
alias devboomers='cd /local/mnt/workspace/mboyns/bds/dev/Boomers'
alias devolympic='cd /local/mnt/workspace/mboyns/bds/dev/Olympic'
alias ads='cd /local/mnt/workspace/mboyns/ads/HEAD'
alias senses='cd /local/mnt/workspace/mboyns/senses'
alias sandbox='cd /local/mnt/workspace/mboyns/bds/sandbox/mboyns/projects/development'
alias pathfinder='cd /local/mnt/workspace/mboyns/depot/pathfinder'

## Solaris
alias df='/bin/df -k'
#alias ps="/bin/ps -o 'user pid pcpu pmem vsz rss tty s time comm'"

unset inside_bashrc
unset interactive
