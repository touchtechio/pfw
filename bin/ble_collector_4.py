#!/usr/bin/python

#
# SeeSaw data collector
#

import os
import sys
import time
import Queue
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

BLE_CMD_CH  = 0;
BLE_CMD_VAL = 1;

IDLE  = 0;
SENSE = 1;
RAW   = 2;

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
        if (bleCmdQueue.empty()):
            periph.waitForNotifications(1.0);
        else:
            bleCmd = bleCmdQueue.get();

            periph.writeCharacteristic(VAL(bleCmd[BLE_CMD_CH]),
                                       bleCmd[BLE_CMD_VAL]);

def reactToData(hr, bw, br):

    print "DATA: {1} {2} {0}".format(hr, bw, br);

    c = OSC.OSCClient();
    c.connect(('127.0.0.1', 12000));
    oscmsg = OSC.OSCMessage();
    oscmsg.setAddress("/data");
    oscmsg.append(hr);
    oscmsg.append(bw);
    oscmsg.append(br);
    c.send(oscmsg);
    return;

# Define notification handling class
class notifHandler(bluepy.btle.DefaultDelegate):
    def __init__(self):
        bluepy.btle.DefaultDelegate.__init__(self);
        return;

    def handleNotification(self, chHandle, data):
        #print("Got data on channel: %s" % NAME(chHandle));
        if (chHandle == yctrlHandle):
            if (data[0] == SEESAW_RET_START_SENSE):
                print("Started Sensing...");
            elif (data[0] == SEESAW_RET_STOP_SENSE):
                print("Stopped Sensing...");
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
                (hr, sdnn) = struct.unpack("<hh", data[1:]);
                reactToData(hr, 0, 0);
                if (verbosePPG):
                    print("PPG: hr = %d, sdnn = %d" % (hr, sdnn));
                ppgData.append([t, hr, sdnn]);
            elif (data[0] == SEESAW_DAT_EEG):
                t = time.time();
                (asym, stress, lpf, rpf) = struct.unpack("<hhhh", data[1:]);
                reactToData(0, stress, 0);
                if (verboseEEG):
                    print("EEG: asym = %d, stress = %d, lpf = %d, rpf = %d" %
                          (asym, stress, lpf, rpf));
                eegData.append([t, asym, stress, lpf, rpf]);
            elif (data[0] == SEESAW_DAT_AUD):
                t = time.time();
                bi = struct.unpack("<h", data[1:]);
                reactToData(0, 0, bi[0]);
                if (verboseAUD):
                    print("AUD: bi = %d" % bi[0]);
                audData.append([t, bi[0]]);
            else:
                print("Got unknown data: %x" % ord(data[0]));
        else:
            print("DATA FROM STRANGE CHANNEL o.o");
        return;

# Init some things
start = False;
dev = None;
state = IDLE;
verbosePPG = False;
verboseEEG = False;
verboseAUD = False;
audData = [];
ppgData = [];
eegData = [];
bleCmdQueue = Queue.Queue();

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

    if (o in ("-s", "--start")):
        print("Start Now");
        start = True;

if (dev == None):
    print("Missing device!");
    sys.exit(-2);

# Connect to BLE device
periph = bluepy.btle.Peripheral();

print("Connecting to device: %s" % dev);
periph.connect(dev);

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
notifThread = threading.Thread(target=notifThreadMain);
notifThread.daemon = True;
notifThread.start();

if (start == True):
    periph.writeCharacteristic(VAL(yctrlHandle), SEESAW_CMD_START_SENSE);
    state = SENSE;

# Main loop
while (True):
    cmd = raw_input(">> ");

    if (len(cmd) == 0):
        continue;

    if (cmd[0] == "h"):
        print("Help:");
        print("");
        print("q, e               leaves the program");
        print("s                  toggle sense mode");
        print("r                  toggle raw mode");
        print("v [metric]         toggle verbose printing of ble packets");
        print("d [metric] [file]  dump collected sense data to file for metric");
        print("c [metric]         clear collected sense data for metric");
        print("h                  print help");
    elif ((cmd[0] == "q") or (cmd[0] == "e")):
        print("Exiting...");
        sys.exit(0);
    elif (cmd[0] == "v"):
        if (len(cmd) != 5):
            print("Bad format: c [metric]");
            continue;

        if ("aud" in cmd):
            verboseAUD = not(verboseAUD);
            print("Prints for AUD: " + str(verboseAUD));
        elif ("ppg" in cmd):
            verbosePPG = not(verbosePPG);
            print("Prints for PPG: " + str(verbosePPG));
        elif ("eeg" in cmd):
            verboseEEG = not(verboseEEG);
            print("Prints for EEG: " + str(verboseEEG));
        elif ("all" in cmd):
            verbosePPG = not(verbosePPG);
            print("Prints for PPG: " + str(verbosePPG));
            verboseAUD = not(verboseAUD);
            print("Prints for AUD: " + str(verboseAUD));
            verboseEEG = not(verboseEEG);
            print("Prints for EEG: " + str(verboseEEG));
        else:
            print("Unknown data metric, options are 'eeg', 'aud', 'ppg', 'all'");
    elif (cmd[0] == "s"):
        bleCmd = [0, 0];
        bleCmd[BLE_CMD_CH] = yctrlHandle;
        if (state == IDLE):
            bleCmd[BLE_CMD_VAL] = SEESAW_CMD_START_SENSE;
            bleCmdQueue.put(bleCmd);
            state = SENSE;
        elif (state == SENSE):
            bleCmd[BLE_CMD_VAL] = SEESAW_CMD_STOP_SENSE;
            bleCmdQueue.put(bleCmd);
            state = IDLE;
        else:
            print("Not in a state where sense mode may be changed");
    elif (cmd[0] == "r"):
        bleCmd = [0, 0];
        bleCmd[BLE_CMD_CH] = yctrlHandle;
        if (state == IDLE):
            bleCmd[BLE_CMD_VAL] = SEESAW_CMD_START_RAW;
            bleCmdQueue.put(bleCmd);
            state = RAW;
        elif (state == RAW):
            bleCmd[BLE_CMD_VAL] = SEESAW_CMD_STOP_RAW;
            bleCmdQueue.put(bleCmd);
            state = IDLE;
        else:
            print("Not in a state where raw mode may be changed");
    elif (cmd[0] == "c"):
        if (len(cmd) != 5):
            print("Bad format: c [metric]");
            continue;

        if ("aud" in cmd):
            audData = [];
            print("Audio data cleared");
        elif ("ppg" in cmd):
            ppgData = [];
            print("PPG data cleared");
        elif ("eeg" in cmd):
            eegData = [];
            print("EEG data cleared");
        elif ("all" in cmd):
            audData = [];
            eegData = [];
            ppgData = [];
            print("All data cleared");
        else:
            print("Unknown data metric, options are 'eeg', 'aud', 'ppg', 'all'");
    elif (cmd[0] == "d"):
        cmdParts = cmd.split(" ");

        if ((len(cmdParts) != 3) or (len(cmdParts[1]) != 3)):
            print("Bad format: d [metric] [file]");
            continue;

        if ("aud" in cmdParts[1]):
            data = [(audData, "aud")];
        elif ("ppg" in cmdParts[1]):
            data = [(ppgData, "ppg")];
        elif ("eeg" in cmdParts[1]):
            data = [(eegData, "eeg")];
        elif ("all" in cmdParts[1]):
            data = [(audData, "aud"), (ppgData, "ppg"), (eegData, "eeg")];
        else:
            print("Unknown data metric, options are 'eeg', 'aud', 'ppg', 'all'");
            continue;

        for d in data:
            if (d[1] == "aud"):
                header = "timestamp, breath interval\n";
            elif (d[1] == "eeg"):
                header = "timestamp, asym, stress, left peak frequency, right peak frequency\n";
            elif (d[1] == "ppg"):
                header = "timestamp, heartrate, sdnn\n";

            s = str(d[0]);
            s = header + s.replace("], [", "\n").replace("[", "").replace("]", "");

            fn = cmdParts[2] + "." + d[1];
            fh = open(fn, 'w');
            fh.write(s);
            fh.close();
            print("Wrote out %s data to %s" % (d[1], fn));
    else:
        print("Unknown command: '%s'" % cmd[0]);
