#!/usr/bin/env python3

import argparse
import os
import re

def main():
    arg_parser = argparse.ArgumentParser(
            description="Removes hard IPs and cloud provided entries from known_hosts",
            formatter_class=argparse.ArgumentDefaultsHelpFormatter,
            )
    arg_parser.add_argument("--dry-run", action="store_true", default=False, help="List entries but do nothing")
    args = arg_parser.parse_args()
    input_file = os.path.expanduser("~/.ssh/known_hosts")

    new_content = []
    nb_rejected = 0
    with open(input_file,'r') as input_file_fd:
        for line in input_file_fd:
            host_desc, key_type, key = line.split(' ')
            first_host = host_desc.split(',')[0] 
            reject = False
            if first_host[:first_host.find(':')] == "[127.0.0.1]" or \
               first_host.endswith('.cloudapp.azure.com') or \
               first_host.endswith('.compute.amazonaws.com') or \
               re.match('\.compute-1\.amazonaws\.com$',first_host) is not None or \
               re.match('^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$',first_host) is not None:
                    reject = True
            if reject:
                nb_rejected += 1
                print(f"Delete {host_desc}")
            else:
                new_content.append(line)
    if not args.dry_run and 0 < nb_rejected:
        with open(input_file,'w') as output_fd:
            output_fd.writelines(new_content)

if __name__ == "__main__":
    main()

