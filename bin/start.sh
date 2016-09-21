#!/bin/bash


# save old display for fixing later
OLD_DISPLAY=$DISPLAY
export DISPLAY=:0

# killing everything
echo "killing everything..."
./stop.sh

echo "running curie ble watcher"
./run-curie-ble.sh > /tmp/intel-ble.log 2>&1 &

#zone setting
echo "ZONE is set to $ZONE"

# default
START_SKETCH=Pfw
if [ $# -eq 1 ]
    then
    START_SKETCH=$1
fi

echo "playing $START_SKETCH"

SKETCH_DIR=/home/intel/Visuals/
#SKETCH_DIR=/media/intel/3662-3362/Visuals

echo "from $SKETCH_DIR/$START_SKETCH/"

cd /home/intel/processing-3.1.1

./processing-java --sketch=$SKETCH_DIR/$START_SKETCH/ --present &> /tmp/intel.log

export DISPLAY=$OLD_DISPLAY

echo "stopped." >> /tmp/intel.log
