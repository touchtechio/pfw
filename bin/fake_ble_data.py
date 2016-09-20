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


import OSC


def reactToData(hr, st, br):

    print "HR: {0} {1} {2}".format(hr, st, br);

    c = OSC.OSCClient();
    c.connect(('127.0.0.1', 12000));
    oscmsg = OSC.OSCMessage();
    oscmsg.setAddress("/data");
    oscmsg.append(hr);
    oscmsg.append(st);
    oscmsg.append(br);
    c.send(oscmsg);
    return;

reactToData(0, 0, 0);

for i in range(15):
    br = random.randrange(1500,6000);
    reactToData(random.randrange(72,100), random.randrange(0,100), br);
    time.sleep(br/1000);

reactToData(99, 15, 2000);
