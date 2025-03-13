#!/bin/sh

trap 'exit 0' SIGTERM

rm /tmp/.X100-lock

while true;
  do
    xpra start --bind-tcp=0.0.0.0:8080 --html=on --start="sudo ./SMS/bin/powerview start -g --no-debug" --daemon=no --xvfb="/usr/bin/Xvfb +extension Composite -screen 0 "$resolution"x24+32 -nolisten tcp -noreset" --pulseaudio=no --notifications=no --bell=no :100
    sleep 5
  done
