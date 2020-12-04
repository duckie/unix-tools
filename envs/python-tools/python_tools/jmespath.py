#!/usr/bin/env python
import json, sys, jmespath;

def main():
    print(jmespath.search(sys.argv[1],json.load(sys.stdin)));

if __name__ == "__main__":
    main()
