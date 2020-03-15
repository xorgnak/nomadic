#!/bin/bash

##
# Nomadic Live Distribution Installer
#
# USAGE: [sudo] ./install.sh
#
## MOVE TO EXTERNAL CONFIG
DISTRO_WM_DEB='cinnamon'
DISTRO_GUI_DEBS="xinit xterm xorg tor chromium-browser audacity electrum tilda scrot"
DISTRO_SYSTEM_DEBS='git emacs emacs-goodies-el vim ruby-full inotify-tools screen redis-server redis-tools openssh-server tor qrencode nmap arp-scan grep wpasupplicant macchanger tshark wifite netcat ii build-essential mosquitto'
DISTRO_GEMS='pry sinatra redis-objects cinch gmail sinatra-pubsub eventmachine rb-inotify mqtt'

## DISTRO_CONFIG
# Output distribution configuration.
DISTRO_NAME='nomadic'
DISTRO_VERSION='desktop'
DISTRO_RELEASE='0.0.1'
DISTRO_NAME_PRETTY="Nomadic $DISTO_VERSION ($DISTRO_RELEASE)"

##
# Internal porcelin variables. 
DIR="$DISTRO_NAME-$DISTRO_VERSION-$DISTRO_RELEASE"

if [[ $1 == '--pretty'  ]]; then
    DEBS="$DISTRO_SYSTEM_DEBS $DISTRO_GUI_DEBS $DISTRO_WM_DEB"
else
    DEBS="$DISTRO_SYSTEM_DEBS"
fi

if [[ $1 == '' ]]; then
    echo "Type YeS to OVERWRITE your SUPER IMPORTANT local bash standard ~/ DOT FILES!!!"
    read yn
    if [[ $yn == 'YeS' ]]; then
    cat << EOF > ~/.xinitrc
xrdb -merge ~/.Xresources
#hash emacs && emacs -fs --visit ~/index.org &
hash tilda && tilda &
hash chromium && chromium --start-fullscreen &
exec $DISTRO_WM_DEB
EOF
cat << EOF > ~/.screenrc
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
cat << 'EOF' > ~/.nomad_prompt/git
Color_Off="\[\033[0m\]"       # Text Reset
Black="\[\033[0;30m\]"        # Black
Red="\[\033[0;31m\]"          # Red
Green="\[\033[0;32m\]"        # Green
Yellow="\[\033[0;33m\]"       # Yellow
Blue="\[\033[0;34m\]"         # Blue
Purple="\[\033[0;35m\]"       # Purple
Cyan="\[\033[0;36m\]"         # Cyan
White="\[\033[0;37m\]"        # White
BBlack="\[\033[1;30m\]"       # Black
BRed="\[\033[1;31m\]"         # Red
BGreen="\[\033[1;32m\]"       # Green
BYellow="\[\033[1;33m\]"      # Yellow
BBlue="\[\033[1;34m\]"        # Blue
BPurple="\[\033[1;35m\]"      # Purple
BCyan="\[\033[1;36m\]"        # Cyan
BWhite="\[\033[1;37m\]"       # White
UBlack="\[\033[4;30m\]"       # Black
URed="\[\033[4;31m\]"         # Red
UGreen="\[\033[4;32m\]"       # Green
UYellow="\[\033[4;33m\]"      # Yellow
UBlue="\[\033[4;34m\]"        # Blue
UPurple="\[\033[4;35m\]"      # Purple
UCyan="\[\033[4;36m\]"        # Cyan
UWhite="\[\033[4;37m\]"       # White
On_Black="\[\033[40m\]"       # Black
On_Red="\[\033[41m\]"         # Red
On_Green="\[\033[42m\]"       # Green
On_Yellow="\[\033[43m\]"      # Yellow
On_Blue="\[\033[44m\]"        # Blue
On_Purple="\[\033[45m\]"      # Purple
On_Cyan="\[\033[46m\]"        # Cyan
On_White="\[\033[47m\]"       # White
IBlack="\[\033[0;90m\]"       # Black
IRed="\[\033[0;91m\]"         # Red
IGreen="\[\033[0;92m\]"       # Green
IYellow="\[\033[0;93m\]"      # Yellow
IBlue="\[\033[0;94m\]"        # Blue
IPurple="\[\033[0;95m\]"      # Purple
ICyan="\[\033[0;96m\]"        # Cyan
IWhite="\[\033[0;97m\]"       # White
BIBlack="\[\033[1;90m\]"      # Black
BIRed="\[\033[1;91m\]"        # Red
BIGreen="\[\033[1;92m\]"      # Green
BIYellow="\[\033[1;93m\]"     # Yellow
BIBlue="\[\033[1;94m\]"       # Blue
BIPurple="\[\033[1;95m\]"     # Purple
BICyan="\[\033[1;96m\]"       # Cyan
BIWhite="\[\033[1;97m\]"      # White
On_IBlack="\[\033[0;100m\]"   # Black
On_IRed="\[\033[0;101m\]"     # Red
On_IGreen="\[\033[0;102m\]"   # Green
On_IYellow="\[\033[0;103m\]"  # Yellow
On_IBlue="\[\033[0;104m\]"    # Blue
On_IPurple="\[\033[10;95m\]"  # Purple
On_ICyan="\[\033[0;106m\]"    # Cyan
On_IWhite="\[\033[0;107m\]"   # White
Time12h="\T"
Time12a="\@"
PathShort="\w"
PathFull="\W"
NewLine="\n"
Jobs="\j"
export PS1=$IGreen$Time12h$Color_Off'$(git branch &>/dev/null;\
if [ $? -eq 0 ]; then \
  echo "$(echo `git status` | grep "nothing to commit" > /dev/null 2>&1; \
  if [ "$?" -eq "0" ]; then \
    # @4 - Clean repository - nothing to commit
    echo "'$Green'"$(__git_ps1 " (%s)"); \
  else \
    # @5 - Changes to working tree
    echo "'$IRed'"$(__git_ps1 " {%s}"); \
  fi) '$BYellow$PathShort$Color_Off'\$ "; \
else \
  # @2 - Prompt when not in GIT repo
  echo " '$Yellow$PathShort$Color_Off'\$ "; \
fi)'
EOF

cat << EOF > ~/index.org
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

cat << EOF > ~/.emacs
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

cat << EOF > ~/.Xresources
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

mkdir -p ~/.config/tilda
cat <<EOF >> ~/.config/tilda/config_0
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

cat << 'EOF' > ~/.nomad_prompt/tools
#!/bin/bash
ANON="false"
PS1="#> "
function discover() {
    IP_REGEXP="(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)"
    IPs=`sudo arp-scan --localnet | grep -E -o $IP_REGEXP`
    sudo nmap -O -F -v $IPs
}
function wifi() {
    WPA=/etc/wpa_supplicant/$1.conf
    if [[ $ANON == "true" ]]; then
	echo "Randomizing MAC address..."
	sudo macchanger -r wlan0
    fi
    if [[ $1 != ''  ]]; then
	if [[ $2 != '' ]]; then
	    echo "Generating $1 configuration..."
	    if [[ $3 != '' ]]; then
		echo "Generating Network configuration..."
		sudo wpa_passphrase "$2" "$3" > $WPA
	    else
		sudo echo "network={
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
	sudo wpa_supplicant -Dwext -iwlan0 -c$WPA &
	echo "Starting DHCP Client..."
	sudo dhclient -v -4 wlan0
    fi    
}

function kill_all_wifi() {
    sudo pkill NetworkManager;
    sudo pkill wpa_supplicant;
    sudo pkill dhclient;
}

function svc() {
  pkill tor
sudo cat <<END >> /etc/tor/torrc
HiddenServiceDir /var/lib/tor/$1/
HiddenServicePort $1 127.0.0.1:$1
END
  tor &
  echo "Your service is at: `cat /var/lib/tor/$1/hostname`";
}
function mnt() {
    mkdir /mnt/$1;
    sudo mount /dev/$1 /mnt/$1;
    echo "DEVICE: /dev/$1 MOUNTED: /mnt/$1";
    ls -lha /mnt/$1;
}
EOF
fi
elif [[ $1 == '-h' ]] || [[ $1 == '--help' ]]; then
    echo "usage: ./nomadic -> install nomadic configuration files locally."
    echo "usage: sudo ./nomadic --server -> install nomadic packages."
    echo "usage: sudo ./nomadic --pretty -> install nomadic packages and desktop."
else
    cat <<EOF > /etc/issue
  ##############################
 ######### NOMADIC LINUX ########
##################################
#@@@@@@@@  @@@@@@@@@@@@@@@@@@@@@@#
#@@@@@@@    @@@@@@@@@@@@@@@@@@@@@#
#@@@@@@@    @@@@@@@@  +@@@@@@@@@@#
#@@@@@@@@  @@  @@@@    @@@@@@@@@@#
#@@@@@@@@@   ; +@@@    @@@@@@@@@@#
#@@@@@@@@+   .  @@@@  ;@  @@@@@@@#
#@@@@@@@@     + +@@@@      @@@@@@#
#@@@@@@@@        @@@@      @@@@@@#
#@@@@@@@@      @@@@@;    # ;@@@@@#
#@@@@@@:  +     @@@@       @@@@@@#
#@@@@@   #@     @@@  +    @@@@@@@#
#@@@@  @@@@,    @.  @@:   ;@@@@@@#
#@@@@@; @@@    @@  @@@+   @@@@@@@#
#@@@@@@ @@;    @@@ +@@    @@@@@@@#
#@@@@@@# @      @@@ @@    @@@@@@@#
#@@@@@@@    :   @@@.;.     @@@@@@#
#@@@@@@@@   @@  #@@@   @   @@@@@@#
#@@@@@@@@   @@,  @@@: .@@  @@@@@@#
#@@@@@@@@  #@@@  @@@.  @@, ;@@@@@#
#@@@@@@@@   @@@, +@@   @@@  @@@@@#
#@@@@@@@: . :@@@  @@   #@@: @@@@@#
#@@@@@@@@  @ @@@: @@ .# @@@  @@@@#
##################################
# No cost. No warranty. No help. #
##################################
 ########### Get Lost. ##########
  ##############################
EOF
    apt -y install $DEBS && gem install --no-ri --no-rdoc $DISTRO_GEMS
fi
