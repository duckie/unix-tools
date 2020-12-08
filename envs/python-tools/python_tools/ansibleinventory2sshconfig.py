#!/usr/bin/env python
import json, sys; 

def main():
    inventory = json.load(sys.stdin)
    hostvars = inventory["_meta"]["hostvars"]
    for host, facts in hostvars.items():
        print_section = False
        section = f"Host {host}\n"
        if "ansible_host" in facts:
            section += f"  Hostname {facts['ansible_host']}\n"
            print_section = True
        if "ansible_user" in facts:
            section += f"  User {facts['ansible_user']}\n"
            print_section = True
        elif "ansible_ssh_user" in facts:
            section += f"  User {facts['ansible_ssh_user']}\n"
            print_section = True
        if print_section:
            print(section)

if __name__ == "__main__":
    main()
