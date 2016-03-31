#!/bin/sh

# Load Xdefaults
if [ -f $HOME/.Xdefaults ]
then
    xrdb -merge $HOME/.Xdefaults
fi

# Load Xmodmap
#if [ -f $HOME/.Xmodmap ]
#then
#    xmodmap $HOME/.Xmodmap
#fi

# Load additional fonts
#fontdirs="$HOME/fonts /usr/lib/X11/fonts/freefont /usr/local/lib/freefont"
#for d in $fontdirs
#do
#    [ -d $d ] && xset fp+ $d
#done
#xset fp rehash

#display=":0.0"
#if [ `hostname` = "doctor" ]
#then
#    display="$display :0.1 :0.2"
#fi

#for d in $display
#do
#    xsetroot -display $d -solid black
#    if [ -f backgrounds/current ]
#    then
#	xv -display $d +noresetroot -root -max -quit backgrounds/current
#    fi
#done

# Run xautolock if available
#if type -path xautolock > /dev/null
#then
#    xautolock &
#fi

# Start a console
#if [ -p /dev/xconsole ]
#then
#    xconsole -iconic -file /dev/xconsole &
#else
#    xconsole -iconic &
#fi

#if type -path procmeter > /dev/null
#then
#    procmeter -geom 100x400-0+100 -fg green -bg black cpu load disk fpkt spkt &
#fi

# Start ssh-askpass
#ssh-add < /dev/null &

#ctwm -W
#fvwm2
#xterm&
#$HOME/fvwm/bin/fvwm2
#$HOME/golem/bin/golem
#$HOME/dist/bin/fvwm2

#xclock -geometry -0-0 -digital -bg black -fg white -update 1 -strftime '%a %b %e %l:%M %p' &
#xterm &
#icewm-session
#e16
#icewm-session-experimental
enlightenment_start
