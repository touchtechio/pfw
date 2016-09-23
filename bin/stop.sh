#!/bin/bash

echo "killing belt processes..."

#kill old start.sh that might be running
echo " ble connecting to a curie"
killall python >/dev/null 2>&1

#kill old start.sh that might be running
echo " killing any visualizations"
killall java >/dev/null 2>&1

echo " killing any ble watchdogs"
ps -fax|grep -B1 curie |grep -v  grep|grep -v "ps -fax"|grep bash|awk '{print $1}'|xargs kill >/dev/null 2>&1

echo " killing any fake data"
ps -fax|grep -B1 fake |grep -v  grep|grep -v "ps -fax"|grep bash|awk '{print $1}'|xargs kill >/dev/null 2>&1

echo "all dead"
