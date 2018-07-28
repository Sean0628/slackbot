#!/bin/bash

readonly THURSDAY=6

if [ $(date +%u) != $THURSDAY ]; then
  exit 1
fi

month=$(date +%m)
next_week_month=$(date -v +7d +%m)
if [ $month != $next_week_month ]; then
  exit 1
fi

ruby ./lib/lunchbot.rb
exit 0
