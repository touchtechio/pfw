#!/usr/bin/python

#
# SeeSaw data collector
#

import os
import sys
import time
import struct
import getopt
import threading
import random
import csv

import OSC


def reactToData(hr, bw, br):

    print "CAPTURED-DATA: {1} {2} {0}".format(hr, bw, br);

    c = OSC.OSCClient();
    c.connect(('127.0.0.1', 12000));
    oscmsg = OSC.OSCMessage();
    oscmsg.setAddress("/data");
    oscmsg.append(hr);
    oscmsg.append(bw);
    oscmsg.append(br);
    c.send(oscmsg);
    return;


reactToData(0, 0, 0);

with open('bio-data.csv', 'rb') as csvfile:
    bioreader = csv.reader(csvfile, delimiter=',')
    for row in bioreader:
        reactToData(row[0], row[1], row[2]);
        print ', '.join(row)
        time.sleep(0.2);

reactToData(99, 15, 2000);