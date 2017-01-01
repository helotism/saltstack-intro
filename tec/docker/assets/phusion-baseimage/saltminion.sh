#!/bin/sh
exec /usr/bin/salt-minion --log-file=/var/log/salt/salt-minion.log --log-file-level=debug
