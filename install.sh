#!/bin/bash

DEV='emacs emacs-goodies-el vim ruby-full'
SYS='inotify-tools screen redis-server openssh-server tor'
GEMS="pry sinatra redis-objects cinch thin"

USERNAME=$1
DEBS="$DEV $SYS"
SKEL=/etc/skel
DEFAULTS=/etc/defaults


if [[ $1 == '' ]]; then
    echo "usage: [sudo] ./nomadic.sh <username> [--gui]"
    exit
fi

i=/etc/issue
echo -e "   .#@@@@@@@@@@@@@@@@@@@@@@@@#." > $i
echo -e "     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" >> $i
echo -e "      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" >> $i
echo -e "      .@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@." >> $i
echo -e "      #@@@@@@@@@@@ NOMADIC @@@@@@@@@@@@#" >> $i
echo -e "      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" >> $i
echo -e "      @@@@@@@@@  @@@@@@@@@@@@@@@@@@@@@@@" >> $i
echo -e "      @@@@@@@@    @@@@@@@@@@@@@@@@@@@@@@" >> $i
echo -e "      @@@@@@@@    @@@@@@@@  +@@@@@@@@@@@" >> $i
echo -e "      @@@@@@@@@  @@  @@@@    @@@@@@@@@@@" >> $i
echo -e "      @@@@@@@@@@   ; +@@@    @@@@@@@@@@@" >> $i
echo -e "      @@@@@@@@@+   .  @@@@  ;@  @@@@@@@@" >> $i
echo -e "      @@@@@@@@@     + +@@@@      @@@@@@@" >> $i
echo -e "      @@@@@@@@@        @@@@      @@@@@@@" >> $i
echo -e "      @@@@@@@@@      @@@@@;    # ;@@@@@@" >> $i
echo -e "      @@@@@@@:  +     @@@@       @@@@@@@" >> $i
echo -e "      @@@@@@   #@     @@@  +    @@@@@@@@" >> $i
echo -e "      @@@@@  @@@@,    @.  @@:   ;@@@@@@@" >> $i
echo -e "      @@@@@@; @@@    @@  @@@+   @@@@@@@@" >> $i
echo -e "      @@@@@@@ @@;    @@@ +@@    @@@@@@@@" >> $i
echo -e "      @@@@@@@# @      @@@ @@    @@@@@@@@" >> $i
echo -e "      @@@@@@@@    :   @@@.;.     @@@@@@@" >> $i
echo -e "      @@@@@@@@@   @@  #@@@   @   @@@@@@@" >> $i
echo -e "      @@@@@@@@@   @@,  @@@: .@@  @@@@@@@" >> $i
echo -e "      @@@@@@@@@  #@@@  @@@.  @@, ;@@@@@@" >> $i
echo -e "      @@@@@@@@@   @@@, +@@   @@@  @@@@@@" >> $i
echo -e "      @@@@@@@@: . :@@@  @@   #@@: @@@@@@" >> $i
echo -e "      @@@@@@@@@  @ @@@: @@ .# @@@  @@@@@" >> $i
echo -e "      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" >> $i
echo -e "      #@@@@@@@@@@@@@ LINUX @@@@@@@@@@@@#" >> $i
echo -e "      .@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@." >> $i
echo -e "        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" >> $i
echo -e "           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" >> $i
echo -e "    	       .#@@@@@@@@@@@@@@@@@@@@@@@@#." >> $i

cat << EOF > $SKEL/.screenrc 
shell -${SHELL}
caption always "[ %t(%n) ] %w"
defscrollback 1024
startup_message off
hardstatus on
hardstatus alwayslastline
screen -t emacs 0 emacs -nw --visit ~/index.org
EOF

cat << EOF > $SKEL/index.org
This will contain the initial help text for nomadic linux. 
EOF

cat <<EOF >> /etc/tor/torrc
# Nomadic services
HiddenServiceDir /var/lib/tor/http/
HiddenServicePort 80 127.0.0.1:4567
HiddenServiceDir /var/lib/tor/irc/
HiddenServicePort 6667 127.0.0.1:6667
HiddenServiceDir /var/lib/tor/ssh/
HiddenServicePort 22 127.0.0.1:22
EOF

#############################
apt-get -y install $DEBS
gem install $GEMS
#############################
if [[ $2 == '--gui' ]]; then
    echo 'startx' >> $SKEL/.profile
    git clone git://git.suckless.org/dwm
    cp lib/dwm.config.h dwm/config.h
    cp lib/gui.sh dwm/
    cp lib/nomadic_wallpaper.jpg dwm/
    ./gui.sh
fi

userdel $USERNAME
rm -fR /home/$USERNAME
useradd --shell /bin/bash -m $USERNAME
usermod -a -G sudo $USERNAME
echo "$USERNAME ALL = (ALL) ALL" >> /etc/sudoers
echo "**** SET YOUR NEW PASSWORD FOR $USERNAME ***"
passwd $USERNAME
