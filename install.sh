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
    chmod +x system.sh
    sudo ./system.sh
fi
