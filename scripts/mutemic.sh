#!/bin/bash

pactl set-source-mute @DEFAULT_SOURCE@ toggle && kill -SIGUSR1 $(pgrep dwm_status.py)
