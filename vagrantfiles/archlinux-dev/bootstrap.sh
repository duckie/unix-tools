#!/usr/bin/env bash

# Add archfr repo
has_archfr=$(grep -c archlinuxfr /etc/pacman.conf)
if [[ 0 == ${has_archfr} ]]; then
  cat << EOF >> /etc/pacman.conf

[archlinuxfr]
SigLevel = Never
Server = http://repo.archlinux.fr/\$arch
EOF
fi

# Install software
pacman -Suy --noconfirm
pacman -S --noconfirm --needed autoconf automake bash bash-completion binutils bison boost boost-libs bzip2 clang clang-analyzer clang-tools-extra cmake coreutils cracklib cryptsetup curl diffutils docker elfutils fakeroot file filesystem findutils flex gawk gc gcc gcc-libs gd gdb gdbm gettext git glib2 glibc gnupg gnutls grep groff gtest gzip htop iftop inetutils iproute2 iputils less libevent logrotate lsof lua lz4 lzo m4 make man-db man-pages ncurses net-tools netctl netstat-nat openresolv openssh openssl pacman pacman-mirrorlist pkg-config pkgfile procps-ng python python2 readline ruby sed strace sudo sysfsutils sysstat tar tig tmux tzdata valgrind vi vim vim-runtime which xz yaourt zlib zziplib rsync go ninja
