#!/usr/bin/env python3

import argparse
import sys
import datetime

parser = argparse.ArgumentParser(description="Prefixs every stdin line with log infos")
parser.add_argument("-n","--name",type=str, default=None, help="Add a fixed name to each log line")
parser.add_argument("-d","--date",type=str, default=None, help="Add time and date of writing to each line")
args = parser.parse_args()
