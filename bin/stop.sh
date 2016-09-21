#!/bin/bash



#kill old start.sh that might be running
echo "killing any python running..."
killall python


#kill old start.sh that might be running
echo "killing any java running..."
killall java

echo "killing any bash running curie..."
ps -fax|grep -B1 curie |grep -v  grep|grep -v "ps -fax"|grep bash|awk '{print $1}'|xargs kill
