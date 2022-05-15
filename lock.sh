#!/bin/bash

betterlockscreen -l --off 5 -- -e --ring-color=5e81acff --inside-color=2e3440ff \
    --insidever-color=88c0d0ff --ringver-color=88c0d0ff --insidewrong-color=d08770ff \
    --ringwrong-color=d08770ff --line-color=2e3440ff --keyhl-color=2e3440ff --bshl-color=d8dee9ff \
    --separator-color=5e81acff

systemctl suspend
