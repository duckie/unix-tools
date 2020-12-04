#!/usr/bin/env python
import yaml, json, sys; 

def main():
    print(yaml.safe_dump(json.load(sys.stdin),default_flow_style=False))

if __name__ == "__main__":
    main()
