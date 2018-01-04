#!/usr/bin/env python2

import process

def stdout(line):
    print("stdout: " + line)

def stderr(line):
    print("stderr: " + line)


piped_process = process.CallablePipedProcess(["./input_test.sh"], stdout=stdout, stderr=stderr, shell=False)
piped_process.wait()

