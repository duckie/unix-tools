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

        self._rout, self._wout = os.pipe()
        self._rerr, self._werr = os.pipe()
        self._fds = {}
        self._fds[self._rout] = {"func":func_out, "end":False}
        self._fds[self._rerr] = {"func":func_err, "end":False}

        kwargs["stdout"] = self._wout
        kwargs["stderr"] = self._werr
        kwargs["close_fds"] = True
        self.process = subprocess.Popen(*args, **kwargs)

    def wait(self, timeout=-1):
        sep = "\n" # Might become a parameter
        event_loop = select.epoll()
        buffers = {}
        for fd, values in self._fds.items():
            event_loop.register(fd, select.EPOLLIN)
            values["buffer"] = ""

        time_remaining = timeout
        while True:
            events = event_loop.poll(timeout=.1)
            for fd, event in events:
                values = self._fds[fd]
                if event & select.EPOLLIN and not event & select.EPOLLERR:
                    data = os.read(fd, 8192)
                    if 0 == len(data):
                        values["func"](values["buffer"])
                        self._fds[fd]["end"] = True
                    else:
                        chunks = data.split(sep)
                        if 1 == len(chunks):
                            self._fds[fd]["buffer"] += chunks[0]
                        else:
                            values["func"](values["buffer"]+chunks[0])
                            for chunk in chunks[1:-1]:
                                values["func"](chunk)
                            self._fds[fd]["buffer"] = chunks[-1]
                if event & select.EPOLLERR:
                    values["func"](values["buffer"])
                    self._fds[fd]["end"] = True
                else:
                    print("Unexpected event")

            # If all are finished, we leave
            finished = True
            for fd, values in self._fds:
                finished = finished and values["end"]
            if finished:
                break
        return self.process.wait()

    def __enter__(self):
        pass

    def __exit__(self, type, value, tb):
        os.close(self._rout)
        os.close(self._rerr)
        

