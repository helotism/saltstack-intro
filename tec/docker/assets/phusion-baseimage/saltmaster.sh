#!/bin/sh
exec /usr/bin/salt-master -d --log-file=/var/log/salt/salt-master.log --log-file-level=debug
