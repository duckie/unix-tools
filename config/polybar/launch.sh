#!/bin/bash

killall -q polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done
source ~/.config/polybar/variables.sh
polybar main &

