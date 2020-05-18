import sys, getpass
from notebook.auth import passwd

try:
    if len(sys.argv) > 1:
        sha1=passwd(sys.argv[1])
    else:
        sha1=passwd()
    print(sha1)
except:
    pass
