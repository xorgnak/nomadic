#!/bin/bash

# NOMADIC GUI

# install dependancies.
apt-get install libxft-dev libxinerama-dev suckless-tools xterm chromium vlc xinit xorg alsa-base alsa-utils

# create shared library directory
mkdir -p /var/lib/nomadic
# install stock .xinitrc file.
# changed:
#  status: ip, battery, temp, time0, time1
#  autostart: background, terminal, bluetooth, browser
#  xterm: colors, keymap

cat << EOF > /etc/skel/.xinitrc
#!/bin/bash
xrdb -merge ~/.Xresources
xmodmap ~/.Xmodmap
hash feh && feh --bg-max /var/lib/nomadic/wallpaper.jpg
hash xterm && xterm -e 'screen' &
hash chromium && chromium &
while true
do
        VOL=$(amixer get Master | tail -1 | sed 's/.*\[\([0-9]*%\)\].*/\1/')
        LOCALTIME=$(date +%Z\=%H:%M)
        OTHERTIME=$(TZ=America/Chicago date +%Z\=%H:%M)
        IP=$(for i in `ip r`; do echo $i; done | grep -A 1 src | tail -n1) # can get confused if you use vmware
        TEMP="$(($(cat /sys/class/thermal/thermal_zone0/temp) / 1000))C"
        xsetroot -name "$IP $VOL $TEMP $LOCALTIME $OTHERTIME <[ N ]"
        sleep 20s
done &
exec dwm
EOF

# build custom dwm and install.
make install
