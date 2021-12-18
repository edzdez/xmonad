#!/bin/bash

contents=$(cat $HOME/.config/xmonad/xmonad.log)
echo $contents | awk -F ":" '{print $2}' | awk '{print $2}'
