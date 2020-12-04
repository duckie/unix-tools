#!/usr/bin/env python3
# -*- encoding: UTF-8 -*-

import argparse
import subprocess
import sys
import os
import json

def main():
    arg_list= list(sys.argv)[1:]
    for line in sys.stdin:
      for arg in arg_list:
        try:
          data = json.loads(line)
          print(arg.format(**data))
        except:
          # Try as csv
          data = line[:-1].split(";")
          print(arg.format(*data))

if __name__ == "__main__":
    main()
