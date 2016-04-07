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
DISTRO_VERSION='desktop'
DISTRO_RELEASE='0.0.1'
DISTRO_NAME_PRETTY="Nomadic - Desktop Edition ($DISTRO_RELEASE)"
DISTRO_LOGO='nomadic.png'
DISTRO_WM_DEB='cinnamon'
DISTRO_GUI_DEBS="xinit xterm xorg tor chromium audacity electrum tilda scrot"
DISTRO_SYSTEM_DEBS='git emacs emacs-goodies-el vim ruby-full inotify-tools screen redis-server openssh-server tor qrencode nmap arp-scan grep wpasupplicant macchanger tshark wifite netcat ii'
DISTRO_GEMS='pry sinatra redis-objects cinch gmail'

##
# Code base config
DEBIAN_RELEASE='jessie'
DEBIAN_FLAVORS='i386'

##
# Internal porcelin variables. 
DIR="$DISTRO_NAME-$DISTRO_VERSION-$DISTRO_RELEASE"
DEBS="$DISTRO_SYSTEM_DEBS $DISTRO_GUI_DEBS $DISTRO_WM_DEB"

##
# Internal helper variables.
HOOK="config/hooks"
ROOT="config/includes.chroot/root"
BIN_R="config/includes.binary/root"
SKEL="config/includes.chroot/etc/skel"
BIN_S="config/includes.binary/etc/skel"
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
mkdir -p $BIN_S
mkdir -p $BIN_R
#mkdir -p $ISOLINUX

echo "$DEBS" > $PACKAGES/$DISTRO_NAME.list.chroot
echo "$DEBS" > $PACKAGES/$DISTRO_NAME.list.binary

##
# STAGE THREE

cat << EOF | tee $SEED/$DISTRO_NAME.cfg.chroot $SEED/$DISTRO_NAME.cfg.binary
d-i partman-auto/choose_recipe select atomic
tasksel tasksel/first multiselect standard $DISTRO_WM-desktop
d-i pkgsel/include string $DEBS
EOF

cat << EOF | tee $HOOK/0666-$DISTRO_NAME.hook.chroot $HOOK/0666-$DISTRO_NAME.hook.chroot
apt-get -y install ruby-full && gem install --no-ri --no-rdoc $DISTRO_GEMS
EOF

cat <<EOF | tee $SKEL/.xinitrc $BIN_S/.xinitrc
xrdb -merge ~/.Xresources
#hash emacs && emacs -fs --visit ~/index.org &
hash tilda && tilda &
hash chromium && chromium --start-fullscreen &
exec $DISTRO_WM_DEB
EOF

cat << EOF | tee $SKEL/.screenrc $BIN_S/.screenrc
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

cat << EOF | tee $SKEL/index.org $BIN_S/index.org
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

cat << EOF | tee $SKEL/.emacs $BIN_S/.emacs
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector
   ["#242424" "#e5786d" "#95e454" "#cae682" "#8ac6f2" "#333366" "#ccaa8f" "#f6f3e8"])
 '(custom-enabled-themes (quote (tsdh-dark))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
EOF

cat << EOF | tee $SKEL/.Xresources $BIN_S/.Xresources
! XTERM -----------------------------------------------------------------------
XTerm*locale: true
XTerm*termName:        xterm-256color
XTerm*internalBorder:        0
XTerm*scrollBar:         false
!XTerm*rightScrollBar: true
XTerm*scrollKey: true
XTerm*scrollTtyOutput: false
XTerm*cursorBlink:       true
XTerm*saveLines:         65535
XTerm*dynamicColors:        on
XTerm*highlightSelection: true
XTerm*utf8:            2
XTerm*cursorColor: #DCDCCC
XTerm*background:  #3f3f3f
XTerm*foreground:  #dcdccc
XTerm*color0:      #1E2320
XTerm*color1:      #705050
XTerm*color2:      #60b48a
XTerm*color3:      #dfaf8f
XTerm*color4:      #506070
XTerm*color5:      #dc8cc3
XTerm*color6:      #8cd0d3
XTerm*color7:      #dcdccc
XTerm*color8:      #709080
XTerm*color9:      #dca3a3
XTerm*color10:     #c3bf9f
XTerm*color11:     #f0dfaf
XTerm*color12:     #94bff3
XTerm*color13:     #ec93d3
XTerm*color14:     #93e0e3
XTerm*color15:     #ffffff
EOF

mkdir -p $SKEL/.config/tilda
mkdir -p $BIN_S/.config/tilda

cat <<EOF | tee $SKEL/.config/tilda/config_0 $BIN_S/.config/tilda/config_0
tilda_config_version = "1.1.12"
# image = ""
command = "screen"
font = "Monospace 11"
key = "F2"
addtab_key = "<Shift><Control>t"
fullscreen_key = "F11"
closetab_key = "<Shift><Control>w"
nexttab_key = "<Control>Page_Down"
prevtab_key = "<Control>Page_Up"
movetableft_key = "<Shift><Control>Page_Up"
movetabright_key = "<Shift><Control>Page_Down"
gototab_1_key = "<Alt>1"
gototab_2_key = "<Alt>2"
gototab_3_key = "<Alt>3"
gototab_4_key = "<Alt>4"
gototab_5_key = "<Alt>5"
gototab_6_key = "<Alt>6"
gototab_7_key = "<Alt>7"
gototab_8_key = "<Alt>8"
gototab_9_key = "<Alt>9"
gototab_10_key = "<Alt>0"
copy_key = "<Shift><Control>c"
paste_key = "<Shift><Control>v"
quit_key = "<Shift><Control>q"
title = "Tilda"
background_color = "white"
# working_dir = ""
web_browser = "x-www-browser"
word_chars = "-A-Za-z0-9,./?%&#:_"
lines = 100
max_width = 1254
max_height = 614
min_width = 1
min_height = 1
transparency = 52
x_pos = 13
y_pos = 0
tab_pos = 0
backspace_key = 0
delete_key = 1
d_set_title = 0
command_exit = 2
scheme = 1
slide_sleep_usec = 20000
animation_orientation = 0
timer_resolution = 200
auto_hide_time = 2000
on_last_terminal_exit = 0
palette_scheme = 0
show_on_monitor_number = 0
palette = {11822, 13364, 13878, 52428, 0, 0, 20046, 39578, 1542, 50372, 41120, 0, 13364, 25957, 42148, 30069, 20560, 31611, 1542, 38944, 39578, 54227, 55255, 53199, 21845, 22359, 21331, 61423, 10537, 10537, 35466, 58082, 13364, 64764, 59881, 20303, 29298, 40863, 53199, 44461, 32639, 43176, 13364, 58082, 58082, 61166, 61166, 60652}
scrollbar_pos = 2
back_red = 0
back_green = 0
back_blue = 0
text_red = 0
text_green = 65535
text_blue = 0
scroll_background = true
scroll_on_output = false
notebook_border = true
antialias = true
scrollbar = false
use_image = false
grab_focus = true
above = true
notaskbar = true
bold = true
blinks = true
scroll_on_key = true
bell = true
run_command = true
pinned = true
animation = true
hidden = true
centered_horizontally = true
centered_vertically = false
enable_transparency = true
double_buffer = true
auto_hide_on_focus_lost = false
auto_hide_on_mouse_leave = false
EOF

cat << 'EOF' | tee $ROOT/leah.sh $BIN_R/leah.sh
#!/bin/bash
ANON="true"
PS1="#> "
function discover() {
    IP_REGEXP="(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)"
    IPs=`sudo arp-scan --localnet | grep -E -o $IP_REGEXP`
    nmap -O -F -v $IPs
}
function wifi() {
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

function hidden_service() {
  pkill tor
cat <<END >> /etc/tor/torrc
HiddenServiceDir /var/lib/tor/$1/
HiddenServicePort $1 127.0.0.1:$1
END
  tor &
  echo "Your service is at: `cat /var/lib/tor/$1/hostname`"
}
function mnt() {
    mkdir /mnt/$1
    mount /dev/$1 /mnt/$1
    ls -lha /mnt/$1
}
echo "############################"
echo "# Dont do anything stupid. #"
echo "############################"
EOF

# wait for update changing syslinux/weezy -> isolinux/jessie issue.
#cp -Rvv /usr/share/live/build/bootloaders/isolinux config/bootloaders/isolinux
#cp -vv $DISTRO_LOGO config/bootloaders/isolinux/splash.png

##
# TRAMP STAMP

cat <<EOF | tee $HOOK/9999-update-issue.hook.chroot $HOOK/9999-update-issue.hook.binary
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
