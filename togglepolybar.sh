#!/bin/bash

if ! pgrep -x "polybar" > /dev/null
then
    $HOME/.config/xmonad/launch_ewmh.sh
else
    killall "polybar"
fi
