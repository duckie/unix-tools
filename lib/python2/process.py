#!/usr/bin/env python2

import subprocess
import select
import os

class CallablePipedProcess(object):
    def __init__(self,*args,**kwargs):
        func_out = kwargs.get("stdout",None)
        func_err = kwargs.get("stderr",None)
        if not callable(func_out) or not callable(func_err):
            raise ValueError("The stdout and stderr arguments of CallablePipedProcess ctor must both be callables")

        #self._rout, self._wout = os.pipe()
        #self._rerr, self._werr = os.pipe()
        self._fds = {}

        kwargs["stdout"] = subprocess.PIPE
        kwargs["stderr"] = subprocess.PIPE
        kwargs["close_fds"] = True
        self.process = subprocess.Popen(*args, **kwargs)
        self._fds[self.process.stdout.fileno()] = {"func":func_out, "end":False}
        self._fds[self.process.stderr.fileno()] = {"func":func_err, "end":False}

    def wait(self, timeout=-1):
        sep = "\n" # Might become a parameter
        for fd, values in self._fds.items():
            values["buffer"] = ""

        time_remaining = timeout
        while True:
            readable, _, exception = select.select(self._fds.keys(), [], self._fds.keys(), .1)
            for fd in readable:
                values = self._fds[fd]
                data = os.read(fd, 8192)
                if 0 == len(data):
                    values["func"](values["buffer"])
                    self._fds[fd]["end"] = True
                    print("Sup")
                else:
                    chunks = data.split(sep)
                    if 1 == len(chunks):
                        self._fds[fd]["buffer"] += chunks[0]
                    else:
                        values["func"](values["buffer"]+chunks[0])
                        for chunk in chunks[1:-1]:
                            values["func"](chunk)
                        self._fds[fd]["buffer"] = chunks[-1]
            for fd in exception:
                values = self._fds[fd]
                if 0 < len(values["buffer"]):
                    values["func"](values["buffer"])
                self._fds[fd]["end"] = True

            # If all are finished, we leave
            finished = True
            for fd, values in self._fds.items():
                finished = finished and values["end"]
            if finished or self.process.poll() is not None:
                break

        return self.process.wait()

    def __enter__(self):
        pass

    def __exit__(self, type, value, tb):
        #os.close(self._rout)
        #os.close(self._rerr)
        pass
        

