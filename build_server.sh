#!/bin/bash

##
# Nomadic Live Distribution Builder
#
# DEPENDANCIES:  apt-get -y install live-build
#
# USAGE: [sudo] ./nomadic-live-build.sh [external configuration]
#

##
# Output distribution configuration.
DISTRO_NAME='nomadic'
DISTRO_VERSION='server'
DISTRO_RELEASE='0.0.1'
DISTRO_NAME_PRETTY="Nomadic - Server Edition ($DISTRO_RELEASE)"
DISTRO_SYSTEM_DEBS='git emacs emacs-goodies-el vim ruby-full inotify-tools screen redis-server openssh-server tor qrencode nmap nmap arp-scan grep wpasupplicant macchanger tshark wifite netcat ii'
DISTRO_GEMS='pry sinatra redis-objects cinch gmail'

##
# Code base config
DEBIAN_RELEASE='jessie'
DEBIAN_FLAVORS='i386'

##
# Internal porcelin variables. 
DIR="$DISTRO_NAME-$DISTRO_VERSION-$DISTRO_RELEASE"
DEBS="$DISTRO_SYSTEM_DEBS"

##
# Internal helper variables.
HOOK="config/hooks"
ROOT="config/includes.chroot/root"
SKEL="config/includes.chroot/etc/skel"
PACKAGES="config/package-lists"
SEED='config/preseed'
ISOLINUX='config/bootloaders/isolinux'

if [[ $1 != '' ]]; then
    source $1
fi

mkdir -p $DIR
cd $DIR

lb clean

##
# STAGE ONE

lb config --verbose \
   -d $DEBIAN_RELEASE \
   -a $DEBIAN_FLAVORS \
   --debian-installer true \
   --debian-installer-gui true \
   --archive-areas "main contrib non-free"

##
# STAGE TWO

mkdir -p $SKEL
mkdir -p $ROOT
#mkdir -p $ISOLINUX

echo "$DEBS" > $PACKAGES/$DISTRO_NAME.list.chroot

##
# STAGE THREE

cat <<EOF > $HOOK/0600-system-gems-install.hook.chroot
gem install --no-ri --no-rdoc $DISTRO_GEMS
EOF

cat << EOF > $SKEL/.screenrc 
shell -${SHELL}
caption always "[ %t(%n) ] %w"
defscrollback 1024
startup_message off
hardstatus on
hardstatus alwayslastline
screen -t emacs 0 emacs -nw --visit ~/index.org
screen -t bash 1 bash
screen -t pry 2 pry
EOF

cat << EOF > $SKEL/index.org
#+TITLE: Nomadic Linux.
#+TODO: TODO(t!/@) ACTION(a!/@) WORKING(w!/@) | ACTIVE(f!/@) DELEGATED(D!/@) DONE(X!/@)
#+OPTIONS: stat:t html-postamble:nil H:1 num:nil toc:t \n:nil ::nil |:t ^:t f:t tex:t

* Welcome!
  Nomadic linux is built to cope with disasters.  It has a simple set of tools designed to get you up and running quickly and consistantly.  Keep a Spare usb stick in your pocket - you never know when it will come in handy.

* Tools
  - git: The version control system of the future.
  - emacs: The gnu text editor.
  - vim: It's always there.
  - ruby: A dynamic, object oriented, interpreted language.
  - python: A compiled high level language.
  - inotify: Kernel file event notification tools.
  - screen: The gnu terminal multiplexer.
  - redis: A next generation NOsql database.
  - tor: The tor network client tools.
  - nmap: A network analysis tool.
  - tshark: A packet analysis tool.
  - wifite: A simple wireless network decrypter.
  - netcat: The linux network swiss army knife.
  - ii: A tiny filesystem based irc client suitable for scripting.

* Org Mode for fun and profit
  Nomadic linux believes in staying organized.  Org mode keeps notes well organized. Nomadic linux also integrates lots of other tools to automate the process of exporting these files.

EOF

cat <<'EOF' > $ROOT/leah.sh
#!/bin/bash
AUTOSTART=~/.autostart.sh
ANON="false"
PS1="#> "
function scan_local_network() {
    IP_REGEXP="(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)"
    IPs=`sudo arp-scan --localnet | grep -E -o $IP_REGEXP`
    nmap -O -F -v $IPs
}
function connect_wireless() {
    WPA=/etc/wpa_supplicant/$1.conf
    if [[ $ANON == "true" ]]; then
	echo "Randomizing MAC address..."
	macchanger -r wlan0
    fi
    if [[ $1 != ''  ]]; then
	if [[ $2 != '' ]]; then
	    echo "Generating $1 configuration..."
	    if [[ $3 != '' ]]; then
		echo "Generating Network configuration..."
		wpa_passphrase $2 $3 > $WPA
	    else
		echo "network={
ssid="$2"
key_mgmt=NONE
}
" > $WPA
	    fi
	else
	    echo "Using existing configuration for $1:"
	fi
	cat $WPA
	### 3
	echo "Starting Wireless Driver..."
	wpa_supplicant -Dwext -iwlan0 -c$WPA &
	echo "Starting DHCP Client..."
	dhclient -v -4 wlan0
    fi    
}

function start_hidden_http() {
  pkill tor
cat << END >> /etc/tor/torrc
HiddenServiceDir /var/lib/tor/http/
HiddenServicePort 80 127.0.0.1:80
END
  tor &
  cat /var/lib/tor/http/hostname
}

function start_hidden_ssh() {
  pkill tor
cat <<END >> /etc/tor/torrc
HiddenServiceDir /var/lib/tor/ssh/
HiddenServicePort 22 127.0.0.1:22
END
  tor &
  cat /var/lib/tor/ssh/hostname
}

function run_wifite() {
    wifite
}
function run_tshark() {
    tshark $*
}
function mount_hd() {
    mkdir /media/hd
    mount /dev/sda1 /media/hd
}

function mount_sd() {
    mkdir /media/sd
    mount /dev/sdb2 /media/sd
}

alias wifi="connect_wireless" 
alias hack="run_wifite"
alias discover="scan_local_network"
alias spy="run_tshark"
alias tor_http="start_hidden_http"
alias tor_ssh="start_hidden_ssh"
alias leah="source $0; source $AUTOSTART;"
echo "############################"
echo "# Dont do anything stupid. #"
echo "############################"
EOF

##
# TRAMP STAMP

cat <<EOF > $HOOK/9999-update-issue.hook.chroot
cat <<END > /etc/issue
The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.

.#@@@@@@@@@@@@@@@@@@@@@@@@#.
  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   .@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.
   #@@@@@@@@@@@ NOMADIC @@@@@@@@@@@@#
   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   @@@@@@@@@  @@@@@@@@@@@@@@@@@@@@@@@
   @@@@@@@@    @@@@@@@@@@@@@@@@@@@@@@
   @@@@@@@@    @@@@@@@@  +@@@@@@@@@@@
   @@@@@@@@@  @@  @@@@    @@@@@@@@@@@
   @@@@@@@@@@   ; +@@@    @@@@@@@@@@@
   @@@@@@@@@+   .  @@@@  ;@  @@@@@@@@
   @@@@@@@@@     + +@@@@      @@@@@@@
   @@@@@@@@@        @@@@      @@@@@@@
   @@@@@@@@@      @@@@@;    # ;@@@@@@
   @@@@@@@:  +     @@@@       @@@@@@@
   @@@@@@   #@     @@@  +    @@@@@@@@
   @@@@@  @@@@,    @.  @@:   ;@@@@@@@
   @@@@@@; @@@    @@  @@@+   @@@@@@@@
   @@@@@@@ @@;    @@@ +@@    @@@@@@@@
   @@@@@@@# @      @@@ @@    @@@@@@@@
   @@@@@@@@    :   @@@.;.     @@@@@@@
   @@@@@@@@@   @@  #@@@   @   @@@@@@@
   @@@@@@@@@   @@,  @@@: .@@  @@@@@@@
   @@@@@@@@@  #@@@  @@@.  @@, ;@@@@@@
   @@@@@@@@@   @@@, +@@   @@@  @@@@@@
   @@@@@@@@: . :@@@  @@   #@@: @@@@@@
   @@@@@@@@@  @ @@@: @@ .# @@@  @@@@@
   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   #@@@@@@@@@@@@@ LINUX @@@@@@@@@@@@#
   .@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.
     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
           .#@@@@@@@@@@@@@@@@@@@@@@@@#.

$DISTRO_NAME_PRETTY 
Built on: Debian GNU/Linux $DEBIAN_RELEASE
END
EOF

##
# BUILD

lb build
