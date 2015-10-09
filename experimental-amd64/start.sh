#!/bin/sh

[ "$1" = "" ] && (echo "You need to define a URL to authorized keys." && exit 1)

# this will regenerate server keys
dpkg-reconfigure openssh-server

# this will properly register the need authorized key
echo "Downloading authorized key from $1..."
curl "$1" >> ~jenkins/.ssh/authorized_keys
chown jenkins:jenkins -R ~jenkins/.ssh
chmod 600 ~jenkins/.ssh/*

# this will start the SSH daemon in the foreground
exec /usr/sbin/sshd -D -p 22