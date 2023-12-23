# umake4alt

Docker-based script for installing software using [Ubuntu Make](https://github.com/ubuntu/ubuntu-make) into ALT Linux.

Under the hood this script uses Docker to obtain Ubuntu file-system, add Ubuntu Make PPA here, and then install `ubuntu-make` into the container. The created Docker images will be named with `um-` prefix, you can remove them manually later.

For ordinary home user this script expects that `sudo` is installed and enabled using `su -l -c "usermod -a -G wheel $USER; control sudo wheelonly; control sudoers relaxed; control sudoreplay wheelonly; control sudowheel enabled;"` (as in SimplyLinux).

The `umake4alt.sh` takes the same arguments as `umake`. For example one can use `./umake4alt.sh electronics arduino` to install modern Arduino IDE 2.x.

Note: if you have configured proxy in your network, then you can supply its address as the argument to the application - `http_proxy=http://192.168.12.34:8000 ./umake4alt.sh electronics arduino` .

How to start using this script:

1. Install Docker and dependencies to the host ALT Linux system
   
       sudo apt-get update
       sudo apt-get install docker-io git

1. Add current user to the `docker` group
   
       sudo usermod -a -G docker $USER
       sudo systemctl enable docker.{service,socket}
 
   then reboot machine.

1. Clone this repository

       cd ~/Downloads
       git clone https://github.com/N0rbert/umake4alt.git

1. Install some application from Ubuntu Make database

       cd umake4alt
       chmod +x umake4alt.sh
       ./umake4alt.sh electronics arduino

1. Reboot after installing the last package, then enjoy the software from Ubuntu Make on your ALT Linux system.

**Note:** most of the applications install their stuff into `~/.local/share/umake` with desktop icons in `~/.local/share/applications` and `~/.local/share/umake/bin` location is added to `$PATH` variable via `~/.bashrc`; the umake config is located at `~/.config/umake` file.  
To keep user's system stable the following frameworks are not automatically added to environment varibles - `android android-ndk`, `android android-platform-tools`, `dart dart-sdk`, `dart flutter-sdk`, `go go-lang`, `java adoptopenjdk`, `java openjfx`, `kotlin kotlin-lang`, `maven maven-lang`, `nodejs nodejs-lang`, `rust rust-lang`, `web chromedriver`, `web geckodriver`, `web phantomjs`; user can find their paths at subdirectories of `~/.local/share/umake/` and then add to `$PATH` manually.

**Warning:** author of this script can't provide any warranty on data safety in parts of your home-folder. Be careful!

## Known issues

Some packages need manual actions.

### Android NDK

Android NDK requires installation of Clang - install it with:

```
sudo apt-get install /usr/bin/clang
```

### Android Platform Tools

Android Platform Tools requires installation of one package - install it with:

```
sudo apt-get install android-tools
```

### Arduino legacy and Arduino IDE

User should be a member of *uucp* and *dialout* groups - run

```
sudo usermod -a -G uucp,dialout $USER
```

to do so.

Modern Arduino IDE 2.x has some problems with sandbox, which may be temporarily fixed by supplying `--no-sandbox` command-line parameter.  
To fix on desktop-file level use the following one-liner:

```
sed -i "s/^Exec=arduino-ide$/Exec=arduino-ide --no-sandbox/g" ~/.local/share/applications/arduino-ide.desktop
```

and then launch Arduino IDE 2.x from menu as usual.

### Eclipse family

Eclipse needs Java to operate - install it with:

```
sudo apt-get install java-17-openjdk-headless java-17-openjdk-devel
```

### JetBrains CLion and others

JetBrains products need compilers and interpreters depending on user demands.

Minimal set of packages are the following:

```
# CLion (C/C++, Qt)
sudo apt-get install etersoft-build-utils gcc-c++
sudo apt-get install qt5-base-devel qt6-base-devel

# Rider (Mono)
sudo apt-get install mono-devel-full

# RubyMine (Ruby)
sudo apt-get install /usr/bin/erb /usr/bin/irb /usr/bin/rdoc /usr/bin/ri /usr/bin/ruby

# GoLand (Go)
sudo apt-get install golang
```

For other products it may be varied.

### LiteIDE

LiteIDE needs one package to be installed - install it with

```
sudo apt-get install libqt5-core
```

if it is not already installed.

### LightTable

LightTable needs *libgconf* package to be installed by

```
sudo apt-get install libGConf
```

then it may be operational.

### NetBeans

NetBeans needs Java to operate, install it with

```
sudo apt-get install java-17-openjdk-headless java-17-openjdk-devel
```

and then run NetBeans as usual.

### SuperPowers

Superpowers has some problems with sandbox, which may be temporarily fixed by supplying `--no-sandbox` commandline parameter. To fix on desktop-file level use the following one-liner:

```
sed -i "s/^Exec=superpowers$/Exec=superpowers --no-sandbox/g" ~/.local/share/applications/superpowers.desktop
```

and then launch Superpowers from menu as usual.

### Visual Studio Code

Visual Studio Code needs two packages to operate, install them by

```
sudo apt-get install libgtk+2 libGConf
```

if they are not already installed.

Visual Studio Code has some problems with sandbox, which may be temporarily fixed by supplying `--no-sandbox` commandline parameter. To fix on desktop-file level use the following one-liner:

```
sed -i "s/^Exec=visual-studio-code$/Exec=visual-studio-code --no-sandbox/g" ~/.local/share/applications/visual-studio-code.desktop
```

and then launch Visual Studio Code from menu as usual.
