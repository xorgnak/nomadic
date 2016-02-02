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
#+TITLE: $USERNAME's notes.
#+TODO: TODO(t!/@) STAGE1(1!/@) STAGE2(2!/@) STAGE3(3!/@) STAGE4(4!/@) | FUNDED(f!/@) DEFUNDED(d!/@) DELEGATED(D!/@) DONE(X!/@)
EOF

cp /etc/tor/torrc ~/.torrc
cat << EOF >> ~/.torrc                                                                                                                                                                                         
# Nomadic services
HiddenServiceDir /home/$USER/tor/http/ 
HiddenServicePort 80 127.0.0.1:80
HiddenServiceDir /home/$USER/tor/irc/
HiddenServicePort 6667 127.0.0.1:6667
HiddenServiceDir /home/$USER/tor/ssh/
HiddenServicePort 22 127.0.0.1:22
EOF

cat << EOF > ~/.bash_profile
w
df -h -x tmpfs -x udev 
EOF

if [[ $1 == '--reset' ]]; then
    rm -fR ~/*
    rm -fR ~/.*
elif [[ $1 == '--system' ]]; then
    chmod +x system.sh
    sudo ./system.sh
fi

echo "DONE!"
