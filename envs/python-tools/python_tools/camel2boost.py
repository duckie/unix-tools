#!/usr/bin/env python3
import sys, re
input = sys.stdin.readline()

def main():
    print(re.sub(r'[A-Z]', lambda x : "_" + x.group().lower(), input),end="")

if __name__ == "__main__":
    main()
