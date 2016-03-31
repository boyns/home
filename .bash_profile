if [ "$BASH" ]
then
    export SHELL=$BASH
else
    export SHELL=/bin/bash
fi

export INPUTRC=${HOME}/.inputrc
export JAVA_HOME=/local/mnt/workspace/java
export VERTX_HOME=/local/mnt/workspace/vertx
export GRADLE_HOME=/local/mnt/workspace/gradle
export GROOVY_HOME=/local/mnt/workspace/groovy
export NODE_HOME=/local/mnt/workspace/node

append ()
{   
    if [ -d "$2" ]
    then
	eval $1=\$$1:$2
    fi
}

PATH=${HOME}/bin
append PATH /usr/local/bin
append PATH /usr/local/sbin
append PATH $JAVA_HOME/bin
append PATH $VERTX_HOME/bin
append PATH $GRADLE_HOME/bin
append PATH $GROOVY_HOME/bin
append PATH $NODE_HOME/bin
append PATH /bin
append PATH /usr/bin
append PATH /sbin
append PATH /usr/sbin
export PATH

MANPATH=/usr/local/man
append MANPATH /usr/man
append MANPATH /usr/share/man
export MANPATH

case `uname` in
Linux)
    ;;
*)
    LD_LIBRARY_PATH=/usr/local/lib
    append LD_LIBRARY_PATH /usr/lib
    append LD_LIBRARY_PATH /usr/openwin/lib
    append LD_LIBRARY_PATH /usr/dt/lib
    append LD_LIBRARY_PATH /usr/ucblib
    export LD_LIBRARY_PATH
    ;;
esac

if [ -d $HOME/.terminfo ]
then
    export TERMINFO=$HOME/.terminfo
fi

##
##
##
export PAGER=less
export EDITOR=vi
export VISUAL=vi
export PGPPATH=$HOME/.pgp
export CVS_RSH=ssh
#export P4PORT=qisperforce:1666
#export P4PASSWD=foobar
#export P4PORT=qisdeploy:1668
export P4CONFIG=.p4config
export HOME ENV TERM MAIL TERMCAP LOGNAME PS1 PS2

#export ORACLE_HOME=/pkg/oracle/product/client/10.2.0.2
#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$ORACLE_HOME/lib
#append PATH $ORACLE_HOME/bin

#if [ -d /pkg/java/j2sdk1.4.2_09 ]
#then
#    export JAVA_HOME=/pkg/java/j2sdk1.4.2_09
#elif [ -d /pkg/java/jdk1.4 ]
#then
#    export JAVA_HOME=/pkg/java/jdk1.4
#fi

if [ -d /local/mnt/workspace/apache-ant ]
then
  export ANT_HOME=/local/mnt/workspace/apache-ant
  append PATH ${ANT_HOME}/bin
fi

if [ -d /local/mnt/workspace/apache-maven ]
then
  export M2_HOME=/local/mnt/workspace/apache-maven
  append PATH ${M2_HOME}/bin
fi

if [ -z "$inside_bashrc" -a -f ~/.bashrc ]
then
    . ~/.bashrc
fi

# Try to use an existing ssh agent.
if [ -d /tmp/XXXssh-$LOGNAME ]
then
    SSH_AUTHENTICATION_SOCKET=`echo /tmp/ssh-$LOGNAME/agent-socket-*`
    if [ -p $SSH_AUTHENTICATION_SOCKET -a -r $SSH_AUTHENTICATION_SOCKET ]
    then
	echo agent socket $SSH_AUTHENTICATION_SOCKET
	export SSH_AUTHENTICATION_SOCKET
    else
	unset SSH_AUTHENTICATION_SOCKET
    fi
fi

motddir="$HOME/.motd"
if [ -e $HOME/.hushlogin ]
then
    if [ ! -d $motddir ]
    then
        mkdir $motddir
    fi
    cmp -s /etc/motd $motddir/$HOSTNAME
    if [ $? -ne 0 ]
    then
        cat /etc/motd | tee $motddir/$HOSTNAME
    fi
fi
unset motddir

umask 022
ulimit -c 0
ulimit -t unlimited

#stty erase ^H
