#!/bin/bash

DEV='emacs emacs-goodies-el vim ruby-full'
SYS='inotify-tools screen redis-server openssh-server tor'
GEMS="pry sinatra redis-objects cinch thin"
DEBS="$DEV $SYS"

function nomadic_login_logo() {
i=/etc/issue
sudo echo -e "   .#@@@@@@@@@@@@@@@@@@@@@@@@#." > $i
sudo echo -e "     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" >> $i
sudo echo -e "      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" >> $i
sudo echo -e "      .@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@." >> $i
sudo echo -e "      #@@@@@@@@@@@ NOMADIC @@@@@@@@@@@@#" >> $i
sudo echo -e "      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" >> $i
sudo echo -e "      @@@@@@@@@  @@@@@@@@@@@@@@@@@@@@@@@" >> $i
sudo echo -e "      @@@@@@@@    @@@@@@@@@@@@@@@@@@@@@@" >> $i
sudo echo -e "      @@@@@@@@    @@@@@@@@  +@@@@@@@@@@@" >> $i
sudo echo -e "      @@@@@@@@@  @@  @@@@    @@@@@@@@@@@" >> $i
sudo echo -e "      @@@@@@@@@@   ; +@@@    @@@@@@@@@@@" >> $i
sudo echo -e "      @@@@@@@@@+   .  @@@@  ;@  @@@@@@@@" >> $i
sudo echo -e "      @@@@@@@@@     + +@@@@      @@@@@@@" >> $i
sudo echo -e "      @@@@@@@@@        @@@@      @@@@@@@" >> $i
sudo echo -e "      @@@@@@@@@      @@@@@;    # ;@@@@@@" >> $i
sudo echo -e "      @@@@@@@:  +     @@@@       @@@@@@@" >> $i
sudo echo -e "      @@@@@@   #@     @@@  +    @@@@@@@@" >> $i
sudo echo -e "      @@@@@  @@@@,    @.  @@:   ;@@@@@@@" >> $i
sudo echo -e "      @@@@@@; @@@    @@  @@@+   @@@@@@@@" >> $i
sudo echo -e "      @@@@@@@ @@;    @@@ +@@    @@@@@@@@" >> $i
sudo echo -e "      @@@@@@@# @      @@@ @@    @@@@@@@@" >> $i
sudo echo -e "      @@@@@@@@    :   @@@.;.     @@@@@@@" >> $i
sudo echo -e "      @@@@@@@@@   @@  #@@@   @   @@@@@@@" >> $i
sudo echo -e "      @@@@@@@@@   @@,  @@@: .@@  @@@@@@@" >> $i
sudo echo -e "      @@@@@@@@@  #@@@  @@@.  @@, ;@@@@@@" >> $i
sudo echo -e "      @@@@@@@@@   @@@, +@@   @@@  @@@@@@" >> $i
sudo echo -e "      @@@@@@@@: . :@@@  @@   #@@: @@@@@@" >> $i
sudo echo -e "      @@@@@@@@@  @ @@@: @@ .# @@@  @@@@@" >> $i
sudo echo -e "      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" >> $i
sudo echo -e "      #@@@@@@@@@@@@@ LINUX @@@@@@@@@@@@#" >> $i
sudo echo -e "      .@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@." >> $i
sudo echo -e "        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" >> $i
sudo echo -e "           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" >> $i
sudo echo -e "    	       .#@@@@@@@@@@@@@@@@@@@@@@@@#." >> $i
}

cat << EOF > ~/.screenrc 
shell -${SHELL}
caption always "[ %t(%n) ] %w"
defscrollback 1024
startup_message off
hardstatus on
hardstatus alwayslastline
screen -t emacs 0 emacs -nw --visit ~/index.org
EOF

cat << EOF > ~/index.org
#+TITLE: $USERNAME's notes.
#+TODO: TODO(t!/@) STAGE1(1!/@) STAGE2(2!/@) STAGE3(3!/@) STAGE4(4!/@) | FUNDED(f!/@) DEFUNDED(d!/@) DELEGATED(D!/@) DONE(X!/@)
EOF

function configure_tor() {
sudo cat <<EOF >> /etc/tor/torrc
# Nomadic services
HiddenServiceDir /var/lib/tor/http/
HiddenServicePort 80 127.0.0.1:80
HiddenServiceDir /var/lib/tor/irc/
HiddenServicePort 6667 127.0.0.1:6667
HiddenServiceDir /var/lib/tor/ssh/
HiddenServicePort 22 127.0.0.1:22
EOF
}

#############################
function system_install() {
    nomadic_login_logo
    configure_tor
    sudo apt-get -y install $DEBS
    sudo gem install $GEMS
}
#############################

cd ~/
git clone https://github.com/xorgnak/leah.git
cd leah
sudo ./install.sh

cd ~/
git clone https://github.com/xorgnak/clerk.git
cd clerk
sudo ./install.sh

cd ~/
git clone https://github.com/xorgnak/gluon.git
if [[ $1 == '--system' ]]; then
    system_install
fi
