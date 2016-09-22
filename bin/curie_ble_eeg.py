#!/usr/bin/python

#
# SeeSaw data collector
import os
import sys
import time
import struct
import bluepy
import getopt
import threading

import OSC

# Define some constants
YETI_SERVICE_UUID = "f0000000-0114-4000-b000-000000000000";
YETI_CTRL_CH_UUID = "f0003000-0114-4000-b000-000000000000";
YETI_DATA_CH_UUID = "f0000001-0114-4000-b000-000000000000";
YETI_STAT_CH_UUID = "f000000d-0114-4000-b000-000000000000";

SEESAW_CMD_START_SENSE  = "\x2a\x00";
SEESAW_CMD_STOP_SENSE   = "\x2b";
SEESAW_CMD_START_RAW    = "\x1a\x00";
SEESAW_CMD_STOP_RAW     = "\x1b"

SEESAW_RET_ERROR        = "\x40";
SEESAW_RET_START_SENSE  = "\x7a";
SEESAW_RET_STOP_SENSE   = "\x7b";
SEESAW_RET_START_RAW    = "\x6a";
SEESAW_RET_STOP_RAW     = "\x6b";
SEESAW_RET_RAW_COMPLETE = "\x6c";

SEESAW_DAT_PPG = "\x81";
SEESAW_DAT_EEG = "\x83";
SEESAW_DAT_AUD = "\x82";

IDLE = 0;
SENSE = 1;
RAW = 2;

# Define offsets to handles for all descriptors
def DECL(h):
    return h - 1;

def VAL(h):
    return h;

def CUD(h):
    return h + 1;

def CCC(h):
    return h + 2;

def NAME(h):
    if (h == yctrlHandle):
        return "CTRL";
    elif (h == ydataHandle):
        return "DATA";
    elif (h == ystatHandle):
        return "STAT";
    else:
        return "UNKNOWN";

# Define notification "processing" thread
def notifThreadMain():
    while (True):
        try:
            periph.waitForNotifications(1.0);
        except bluepy.btle.BTLEException:
            print "Device disconnected";


# Define notification handling class
class notifHandler(bluepy.btle.DefaultDelegate):
    def __init__(self):
        bluepy.btle.DefaultDelegate.__init__(self);
        return;

    def reactToData(self, hr, st, br):
        print "DATA: {0} {1} {2}".format(hr, st, br);
        print "EEG: {0} {1} {2} {3}".format(asym, idx, l_peak, r_peak);
        print "Breath Duration: {0}".format(br);
        c = OSC.OSCClient();
        c.connect(('127.0.0.1', 12000));
        oscmsg = OSC.OSCMessage();
        oscmsg.setAddress("/data");
        oscmsg.append(hr);
        oscmsg.append(st);
        oscmsg.append(br);
        c.send(oscmsg);
        return;

    def handleNotification(self, chHandle, data):
        #print("Got data on channel: %s" % NAME(chHandle));
        if (chHandle == yctrlHandle):
            if (data[0] == SEESAW_RET_START_SENSE):
                print("Started Sensing...");
            elif (data[0] == SEESAW_RET_STOP_SENSE):
                print("Stopped Sensing...");
                periph.writeCharacteristic(VAL(yctrlHandle), SEESAW_CMD_START_SENSE);
                state = SENSE;
            elif (data[0] == SEESAW_RET_START_RAW):
                print("Started Data Collection...");
            elif (data[0] == SEESAW_RET_STOP_RAW):
                print("Stopped Data Collection...");
            elif (data[0] == SEESAW_RET_RAW_COMPLETE):
                print("Data Collection Complete!");
            elif (data[0] == SEESAW_RET_ERROR):
                print("AN ERROR OCCURRED!");
            else:
                print("Unknown Return Value: %x" % ord(data[0]));
        elif (chHandle == ydataHandle):
            if (data[0] == SEESAW_DAT_PPG):
                t = time.time();
                (hr, st) = struct.unpack("<hh", data[1:]);
                print "HR: {0}".format(hr); 
		#self.reactToData(hr, st, 0);
                ppgData.append([t, hr, st]);
            elif (data[0] == SEESAW_DAT_EEG):
                t = time.time();
                (asym, idx,l_peak,r_peak) = struct.unpack("<hhhh", data[1:]);
                print "EEG: {0} {1} {2} {3}".format(asym, idx, l_peak, r_peak);
                eegData.append([t, 0.0]);
            elif (data[0] == SEESAW_DAT_AUD):
                t = time.time();
                br = struct.unpack("<h", data[1:]);
                print "Breath: {0}".format(br[0]);
                #self.reactToData(0, 0, br[0]);
                audData.append([t, 0.0, 0.0, 0.0]);
            else:
                print("Got unknown data: %x" % ord(data[0]));
        else:
            print("DATA FROM STRANGE CHANNEL o.o");
        return;

# Init some things
dev = None;
state = IDLE;
audData = [];
ppgData = [];
eegData = [];

# Parse args
try:
    op, ar = getopt.getopt(sys.argv[1:], "d:", ["device="]);
except:
    print("Error getting args");
    sys.exit(-1);

for (o, a) in op:
    if (o in ("-d", "--device")):
        print("Device: %s" % a);
        dev = a;

if (dev == None):
    print("Missing device!");
    sys.exit(-2);

# Connect to BLE device
periph = bluepy.btle.Peripheral();

print("Connecting to device: %s" % dev);
try:
    periph.connect(dev);
except bluepy.btle.BTLEException:
    print("failed to connect!")
    sys.exit(0)


# Configure peripheral
periph.withDelegate(notifHandler());

# Get characteristics
yeti = periph.getServiceByUUID(YETI_SERVICE_UUID);
yctrl = yeti.getCharacteristics(YETI_CTRL_CH_UUID)[0];
ydata = yeti.getCharacteristics(YETI_DATA_CH_UUID)[0];
ystat = yeti.getCharacteristics(YETI_STAT_CH_UUID)[0];

yctrlHandle = yctrl.getHandle();
ydataHandle = ydata.getHandle();
ystatHandle = ystat.getHandle();

# Enable notifications for all characteristics
periph.writeCharacteristic(CCC(yctrlHandle), "\x01\x00");
periph.writeCharacteristic(CCC(ydataHandle), "\x01\x00");
periph.writeCharacteristic(CCC(ystatHandle), "\x01\x00");

print("Notifications enabled for all channels");

# Handle multithreading
#notifThread = threading.Thread(target=notifThreadMain);
#notifThread.daemon = True;
#notifThread.start();

periph.writeCharacteristic(VAL(yctrlHandle), SEESAW_CMD_START_SENSE);
state = SENSE;

# Main loop
while (True):
    try:
        periph.waitForNotifications(1.0);
    except bluepy.btle.BTLEException:
        print "Device disconnected";
        sys.exit(-1);
