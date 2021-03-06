#!/usr/bin/env python3
# -*- encoding: UTF-8 -*-

import argparse
import subprocess
import sys
import json
from pprint import pprint
#from itertools import izip

commit_format_json1 = '--pretty=tformat:{"author":{"name":"%an","email":"%ae"},"date":{"relative":"%ar","absolute":"%aD"},"title":"%s","body":"%b"}'
commit_format_expanded = '--pretty=format:%an%n%ae%n%ar%n%aD%n%s'

def execute_command(args):
  result, _ = subprocess.Popen(args, shell=False, stdout=subprocess.PIPE).communicate()
  return result

def fetch():
  # Make sure we are up to date
  execute_command(["git","fetch","--prune"])

def list_merged():
  # List refs
  refs_bulk = execute_command(["git","for-each-ref","refs/remotes/origin","--merged"]).decode("utf-8").split()
  commit_list = []
  branches = []
  for sha1, objType, refName in zip(*[iter(refs_bulk)]*3):
    if objType == "commit":
      if sha1 not in commit_list:
        commit_list.append(sha1)
        branches.append(refName.split("/")[-1])

  # Current behavior is to display by author
  refs_bulk_data = execute_command(["git","show","-s",commit_format_expanded] + commit_list).decode("utf-8").split("\n")
  for branch, commit, (author, email, dateRelative, date, subject) in zip(iter(branches),iter(commit_list),zip(*[iter(refs_bulk_data)]*5)):
    print(json.dumps({
      "branch": branch,
      "commit": commit,
      "author": { "name": author, "email": email },
      "date": { "relative": dateRelative, "standard": date },
      "message": subject
    }))


def trim_local_merged():
    # Get current branch
    current_branch = execute_command(["git","symbolic-ref","--short","HEAD"]).decode("utf-8").strip()

    # Get all merged
    merged_list = execute_command(["git","branch","--format","%(refname:lstrip=2)","--merged"]).decode("utf-8").split()

    # Delete them
    for branch in merged_list:
        if branch != current_branch:
            execute_command(["git","branch","-d",branch])
            print("{} deleted".format(branch))

def main():
    # Parse commad line
    parser = argparse.ArgumentParser(description="Tools to clean a shared git repository")
    #parser.add_argument("version", nargs=1, help="Version of the packages")
    parser.add_argument("--list-merged-tips", action="store_true", help="List data about branch tips already merged")
    parser.add_argument("--trim-local-merged", action="store_true", help="Remove local branches already merged into current branch")
    args = parser.parse_args()

    if args.list_merged_tips:
      fetch()
      list_merged()

    if args.trim_local_merged:
        trim_local_merged()

if __name__ == "__main__":
    main()
