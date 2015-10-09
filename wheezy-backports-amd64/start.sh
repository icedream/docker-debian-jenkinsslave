#!/bin/sh

# this will regenerate server keys
dpkg-reconfigure openssh-server

# this will properly register the need authorized key
curl "$1" >> ~jenkins/.ssh/authorized_keys
chmod 600 ~jenkins/.ssh/*

# this will start the SSH daemon in the foreground
exec /usr/sbin/sshd -D -p 22