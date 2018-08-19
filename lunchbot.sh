#!/bin/bash

readonly THURSDAY=4

if [ $(date +%u) != $THURSDAY ]; then
  exit 1
fi

ruby ./lib/lunchbot.rb
exit 0
