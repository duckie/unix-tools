#!/usr/bin/env python3
import sys, re
input = sys.stdin.readline()

def main():
    print(re.sub(r'_[a-z]', lambda x : x.group()[1:].upper(), input),end="")

if __name__ == "__main__":
    main()
