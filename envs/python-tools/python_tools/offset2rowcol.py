#!/usr/bin/env python3

import argparse,fileinput

def main():
    # Script used to convert an offset to row:column value
    parser = argparse.ArgumentParser(description="Convert offset to row:column")
    parser.add_argument("offset", metavar="OFFSET", nargs=1,help="offset to which make the compuation")
    parser.add_argument("file", metavar="FILE", nargs="?",help="offset to which make the compuation")
    args = parser.parse_args()
    offset = int(args.offset[0])
    nb_lines = 0
    for line in fileinput.input(args.file if args.file is not None else []):
        nb_chars = len(line)
        if offset < nb_chars:
            print("{}:{}".format(nb_lines, offset))
            break
        else:
            offset = offset - nb_chars
            nb_lines += 1

if __name__ == "__main__":
    main()
