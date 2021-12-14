#!/bin/bash

currlayout=$(setxkbmap -query | grep variant | awk '{print $NF}')

if [ -z "$currlayout" ]; then
    echo "intl"
    setxkbmap -layout us -variant intl
else
    echo "us"
    setxkbmap -layout us
fi

setxkbmap -option caps:escape
