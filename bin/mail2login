#!/usr/bin/env python

import re
import sys

login_regex = re.compile("^([a-zA-Z0-9]+(-[a-zA-Z0-9]+)*\.[a-zA-Z0-9]+(-[a-zA-Z0-9]+)*)@.+$")


def build_login_candidate(email, additional_letters=0):
    match = login_regex.match(email)
    if not match:
        return None

    first, last = match.group(1).split(".")
    firsts = first.split("-")
    lasts = last.split("-")

    login = ""
    for name in firsts:
        login += name[0]
        index = 1
        while 0 < additional_letters and index < len(name):
            login += name[index]
            additional_letters -= 1
            index += 1

    for name in lasts:
        login += name

    return login


def main():
    print(
        build_login_candidate(sys.stdin.read().decode("ascii").strip(), 0 if len(sys.argv) < 2 else int(sys.argv[1]),)
    )


if __name__ == "__main__":
    main()
