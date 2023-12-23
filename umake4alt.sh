#!/bin/bash
release=focal

echo "UMake4alt Docker-based script is started."
echo "1. Preparing Docker-container with Ubuntu $release."

cat << EOF > Dockerfile
FROM ubuntu:$release

RUN [ -z "$http_proxy" ] && echo "Using direct network connection" || echo 'Acquire::http::Proxy "$http_proxy";' > /etc/apt/apt.conf.d/99proxy

RUN echo 'deb http://archive.ubuntu.com/ubuntu $release main universe multiverse restricted' > /etc/apt/sources.list
RUN echo 'deb http://archive.ubuntu.com/ubuntu $release-updates main universe multiverse restricted' >> /etc/apt/sources.list
RUN echo 'deb http://archive.ubuntu.com/ubuntu $release-security main universe multiverse restricted' >> /etc/apt/sources.list

RUN dpkg --add-architecture i386
RUN apt-get update && apt-get install -y sudo

RUN groupadd $USER -g $(id --group)
RUN useradd $USER -u $(id --user) -g $(id --group) -G $USER,sudo -m
RUN su -l $USER -c groups
RUN sed -i 's/%sudo	ALL=(ALL:ALL) ALL/$USER  ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers

ENV DEBIAN_FRONTEND noninteractive

RUN mkdir -p /etc/bash_completion.d/
RUN apt-get update && apt-get install -y bash-completion sudo && \
apt-get install software-properties-common gnupg gpg dirmngr --no-install-recommends -y && \
add-apt-repository -y ppa:lyzardking/ubuntu-make && apt-get install -y ubuntu-make
RUN umake -l -v 2>&1 | grep ^INFO | grep "isn't installed" | sed "s|INFO: ||g" | sed "s|isn't installed||g" | grep -v ^libevent | sort -u | tr '\n' ' ' | xargs apt-get install -y
RUN apt-get install -y libevent-dev openjdk-8-jdk avr-libc binutils-avr gcc-avr
EOF

# build container
if [ -z "$(docker images -q um-ubuntu-$release:latest)" ];
then
	docker build --progress=plain -t "um-ubuntu-$release" - < ${PWD}/Dockerfile
	echo "   The image is just built."
else
	echo "   Reusing existing image."
fi

# run script inside container
echo "2. Running umake from Docker-container to perform actions on parts of your home-folder."

mkdir -p ~/.local/share/applications
mkdir -p ~/.local/share/umake
mkdir -p ~/.config

docker run --rm -v $HOME/.local/share/applications:/home/$USER/.local/share/applications -v $HOME/.local/share/umake:/home/$USER/.local/share/umake -v $HOME/.config:/home/$USER/.config --user $(id --user):$(id --group) -it "um-ubuntu-$release" bash -c "umake -l -v 2>&1 | grep ^INFO | grep \"isn't installed\" | sed \"s|INFO: ||g\" | sed \"s|isn't installed||g\" | grep -v ^libevent | sort -u | tr '\n' ' ' | xargs sudo apt-get install -y; umake $*"

grep -q "^PATH=/home/$USER/.local/share/umake/bin/:\$PATH" ~/.bashrc || echo "PATH=/home/$USER/.local/share/umake/bin/:\$PATH" >> ~/.bashrc
source ~/.bashrc
