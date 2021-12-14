#!/bin/bash

pactl set-sink-mute @DEFAULT_SINK@ toggle && kill -SIGUSR1 $(pgrep dwm_status.py)
pkill -RTMIN+2 dwmblocks
