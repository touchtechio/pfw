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

    print "CAPTURED-DATA: {0} {1} {2}".format(hr, bw, br);

    c = OSC.OSCClient();
    c.connect(('127.0.0.1', 12000));
#    c.connect(('10.10.11.16', 12000));
    oscmsg = OSC.OSCMessage();
    oscmsg.setAddress("/data");
    oscmsg.append(int(hr));
    oscmsg.append(int(bw));
    oscmsg.append(int(br));
    c.send(oscmsg);
    return;

reactToData(0, 0, 0);

with open('bio-data.csv', 'rb') as csvfile:
    bioreader = csv.reader(csvfile, delimiter=',')
    for row in bioreader:
        reactToData(row[0], row[1], row[2]);
        #print ', '.join(row)
        time.sleep(1.0);

reactToData(76, 155, 3053);
