#!/bin/bash

DEV='emacs emacs-goodies-el vim ruby-full'
SYS='inotify-tools screen redis-server openssh-server tor'
GEMS="pry sinatra redis-objects cinch thin"
DEBS="$DEV $SYS"

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

cat <<EOF >> /etc/tor/torrc
# Nomadic services
HiddenServiceDir /var/lib/tor/http/
HiddenServicePort 80 127.0.0.1:80
HiddenServiceDir /var/lib/tor/irc/
HiddenServicePort 6667 127.0.0.1:6667
HiddenServiceDir /var/lib/tor/ssh/
HiddenServicePort 22 127.0.0.1:22
EOF

apt-get -y install $DEBS
gem install $GEMS
