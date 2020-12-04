#!/usr/bin/env python3
import yaml, json, sys; 

def main():
    print(json.dumps(yaml.safe_load(sys.stdin),indent=2))

if __name__ == "__main__":
    main()
