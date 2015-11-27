#!/bin/bash

DEV='emacs emacs-goodies-el vim ruby-full'
SYS='inotify-tools screen redis-server openssh-server'
SEC='nmap netcat'
GEMS="pry sinatra redis-objects cinch thin"

DOMAINNAME='nothere'
HOSTNAME='here'

DEBS="$DEV $SYS $SEC"
SKEL=/etc/skel

if [[ $1 == '' ]]; then
    echo "usage: [sudo] ./nomadic.sh <username> [--gui]"
    exit
fi

USERNAME=$1
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
screen -t emacs emacs -nw --funcall erc
EOF

apt-get -y install $DEBS $G
gem install $GEMS
if [[ $2 == '--gui' ]]; then
    echo $MODE >> $SKEL/.profile
    git clone git://git.suckless.org/dwm
    cp gui.sh dwm/
    cp nomadic_wallpaper.jpg dwm/
    cd dwm
    ./gui.sh
fi
domainname $DOMAINNAME
hostname $HOSTNAME
useradd --shell /bin/bash -m $USERNAME
passwd $USERNAME
