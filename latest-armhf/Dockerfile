FROM icedream/debian-armhf:latest
MAINTAINER Carl Kittelberger, it@icedreammusic.eu


# qemu static binaries for potential emulation
COPY qemu-arm-static /usr/bin/


# Prevent initramfs from trying to do bootloader stuff
ENV INITRD no

# Non-interactive debian installation
ENV DEBIAN_FRONTEND noninteractive
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Disable dpkg fsync for speeding up the build of this image
RUN echo force-unsafe-io > /etc/dpkg/dpkg.cfg.d/02-docker-apt-speedup

# Fix issue regarding initctl and APT packages (https://github.com/dotcloud/docker/issues/1024)
RUN dpkg-divert --local --rename --add /sbin/initctl && \
	ln -sf /bin/true /sbin/initctl

# Fix issue regarding ischroot (https://bugs.launchpad.net/launchpad/+bug/974584)
RUN dpkg-divert --local --rename --add /usr/bin/ischroot && \
	ln -sf /bin/true /usr/bin/ischroot

# Install updates + sudo + apt-utils (get rid of that warning)
RUN apt-get update -y && \
	DEBIAN_FRONTEND=noninteractive apt-get install --force-yes -y sudo &&\
	DEBIAN_FRONTEND=noninteractive apt-get install --force-yes -y apt-utils

# install all packages
RUN apt-get install --force-yes -y --no-install-recommends \
		build-essential \
		autotools-dev automake autoconf \
		curl tar zip unzip xz-utils locales wget \
		git subversion cvs mercurial \
		openssh-server apt-transport-https ca-certificates \
		openjdk-7-jre

# set up locale
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
	locale-gen en_US && \
	update-locale LANG=en_US.UTF-8 LC_CTYPE=en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8

# prepare the jenkins user
RUN adduser --disabled-password --gecos "" jenkins && \
	mkdir -p /tmp && \
	chmod 777 /tmp && \
	mkdir /home/jenkins/.ssh && \
	chown jenkins:jenkins /home/jenkins/.ssh && \
	chmod 700 /home/jenkins/.ssh && \
	adduser jenkins sudo

# passwordless sudo for extra package installations, etc.
RUN echo '' >> /etc/sudoers && \
	echo 'jenkins ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# clean up
RUN apt-get autoremove -y && \
	apt-get autoclean && \
	apt-get clean && \
	rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/* \
		/etc/dpkg/dpkg.cfg.d/*-docker-* /etc/ssh/ssh_host_*

# ssh preparation
RUN mkdir -p /var/run/sshd

COPY start.sh /
RUN chmod +x /start.sh
CMD ["/start.sh"]

# SSH for Jenkins master
EXPOSE 22
