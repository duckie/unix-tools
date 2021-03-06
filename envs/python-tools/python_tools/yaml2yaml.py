#!/usr/bin/env python
import yaml;
import json;
import sys;
import argparse;

def main():
    parser = argparse.ArgumentParser(description="Modify the behavior of the transformation")
    parser.add_argument("-s", "--style", choices=["inline","leaf-inline","indent"], default="indent", help="Yaml style to use")
    args = parser.parse_args()

    default_flow_style_value = {
        "inline": True,
        "leaf-inline": None,
        "indent": False,
    }

    print(yaml.safe_dump(yaml.safe_load(sys.stdin),default_flow_style=default_flow_style_value[args.style]))

if __name__ == "__main__":
    main()
