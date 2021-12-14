#!/bin/bash

function run {
 if ! pgrep $1 ;
  then
    $@&
  fi
}

run "lxsession"
run "nitrogen --restore"
run "picom --experimental-backends"
run "wmname LG3D"
run "/usr/lib/xfce4/notifyd/xfce4-notifyd"
run "nm-applet --indicator"
run "pa-applet"
run "setxkbmap -option caps:escape"
run "$HOME/.config/xmonad/launch_ewmh.sh"
