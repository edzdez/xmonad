#!/usr/bin/env bash

systemctl restart --user emacs && notify-send "Restarted Emacs" "Finished Restarting Emacs Daemon."
