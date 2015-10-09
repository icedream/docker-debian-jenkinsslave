#!/bin/sh

# this will regenerate server keys
dpkg-reconfigure openssh-server

# this will start the SSH daemon in the foreground
exec /usr/sbin/sshd -D -p 22