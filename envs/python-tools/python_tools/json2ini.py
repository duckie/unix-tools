#!/usr/bin/env python3

import sys
import json
import collections.abc
import copy

def format_value(value):
    if isinstance(value, str):
        return value
    elif isinstance(value, collections.abc.Iterable):
        return ",".join(value)
    else:
        return str(value)

def print_as_ini(prefix, leaf):
    if isinstance(leaf, collections.abc.Mapping):
        for key, value in leaf.items():
            print_as_ini(prefix+[key], value)
    else:
        print("{} = {}".format(".".join(prefix), format_value(leaf)))


def main():
    print_as_ini([], json.load(sys.stdin))

if __name__ == "__main__":
    main()
