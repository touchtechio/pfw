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


def reactToData(hr, st):

    print "HR: {0} {1}".format(hr, st);

    c = OSC.OSCClient();
    c.connect(('127.0.0.1', 12000));
    oscmsg = OSC.OSCMessage();
    oscmsg.setAddress("/data");
    oscmsg.append(hr);
    oscmsg.append(st);
    c.send(oscmsg);
    return;

reactToData(0, 0);

for i in range(30):
    reactToData(random.randrange(72,100), random.randrange(0,100));
    time.sleep(0.5);

reactToData(99, 50);
