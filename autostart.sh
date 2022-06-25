#!/bin/bash

function run {
 if ! pgrep $1 ;
  then
    $@&
  fi
}

if ! pgrep budgie;
then
    run "lxsession"
    run "nitrogen --restore"
    run "picom --experimental-backends"
    run "/usr/lib/xfce4/notifyd/xfce4-notifyd"
    run "nm-applet --indicator"
    run "pa-applet"
    run "$HOME/.config/xmonad/launch_ewmh.sh"
fi

run "setxkbmap -option caps:escape"
run "wmname LG3D"
