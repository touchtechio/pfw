#!/bin/bash

# save old display for fixing later
OLD_DISPLAY=$DISPLAY
export DISPLAY=:0

# killing everything
echo "stop everything before starting"
./stop.sh

echo "running curie ble watcher to /tmp/intel-ble.log"
#./run-curie-ble.sh > /tmp/intel-ble.log 2>&1 &

SKETCH_DIR=/home/intel/Visuals/

START_SKETCH=Pfw
if [ $# -eq 1 ]
    then
    START_SKETCH=$1
fi

echo "playing $START_SKETCH"
echo " from $SKETCH_DIR/$START_SKETCH/"
echo " with ZONE is set to $ZONE"

cd /home/intel/processing-3.1.1
./processing-java --sketch=$SKETCH_DIR/$START_SKETCH/ --present &> /tmp/intel.log

export DISPLAY=$OLD_DISPLAY

./stop.sh >> /tmp/intel.log
echo "stopped." >> /tmp/intel.log
