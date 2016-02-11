#!/bin/bash

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
#+TITLE: Nomadic Linux.
#+TODO: TODO(t!/@) STAGE1(1!/@) STAGE2(2!/@) STAGE3(3!/@) STAGE4(4!/@) | FUNDED(f!/@) DEFUNDED(d!/@) DELEGATED(D!/@) DONE(X!/@)
EOF

cat << EOF > ~/.xinitrc
xrdb -merge ~/.Xresources
hash chromium && chromium &
hash xterm && xterm -e 'screen' &
while true
do
	VOL=$(amixer get Master | tail -1 | sed 's/.*\[\([0-9]*%\)\].*/\1/')
	LOCALTIME=$(date +%Z\=%Y-%m-%dT%H:%M)
	OTHERTIME=$(TZ=Europe/London date +%Z\=%H:%M)
	IP=$(for i in `ip r`; do echo $i; done | grep -A 1 src | tail -n1) # can get confused if you use vmware
	TEMP="$(($(cat /sys/class/thermal/thermal_zone0/temp) / 1000))C"

	if acpi -a | grep off-line > /dev/null
	then
		BAT="Bat. $(acpi -b | awk '{ print $4 " " $5 }' | tr -d ',')"
		xsetroot -name "$IP $BAT $VOL $TEMP $LOCALTIME $OTHERTIME"
	else
		xsetroot -name "$IP $VOL $TEMP $LOCALTIME $OTHERTIME"
	fi
	sleep 20s
done &
exec dwm
EOF

cat << EOF > ~/.Xresources
! XTERM -----------------------------------------------------------------------
XTerm*locale: true
XTerm*termName:        xterm-256color
XTerm*internalBorder:        0
XTerm*loginShell:         true
XTerm*scrollBar:         false
!XTerm*rightScrollBar: true
XTerm*scrollKey: true
XTerm*scrollTtyOutput: false
XTerm*cursorBlink:       true
!XTerm*geometry:         80x26
XTerm*saveLines:         65535
XTerm*dynamicColors:        on
XTerm*highlightSelection: true
! Appearance
XTerm*utf8:            2
XTerm*eightBitInput:   true
XTerm*metaSendsEscape: true
XTerm*font:        -xos4-terminus-medium-r-*-*-18-*-*-*-*-*-iso10646-*
XTerm*boldFont:    -xos4-terminus-bold-r-*-*-18-*-*-*-*-*-iso10646-*
XTerm*cursorColor: #DCDCCC
! Zenburn
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

### Uncomment for TOR integration.
#cp /etc/tor/torrc ~/.torrc
#cat << EOF >> ~/.torrc                                                                                                                                                                                         
## Nomadic services
#HiddenServiceDir /home/$USER/tor/http/ 
#HiddenServicePort 80 127.0.0.1:80
#HiddenServiceDir /home/$USER/tor/irc/
#HiddenServicePort 6667 127.0.0.1:6667
#HiddenServiceDir /home/$USER/tor/ssh/
#HiddenServicePort 22 127.0.0.1:22
#EOF

echo "DONE!"
