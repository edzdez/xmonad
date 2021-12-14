#!/bin/bash

pactl set-sink-volume @DEFAULT_SINK@ +5% && kill -SIGUSR1 $(pgrep dwm_status.py)
pkill -RTMIN+2 dwmblocks
