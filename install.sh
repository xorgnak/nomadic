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

if [[ $1 == '--reset' ]]; then
    rm -fR ~/*
    rm -fR ~/.*
elif [[ $1 == '--system' ]]; then
    chmod +x system.sh
    sudo ./system.sh
fi
echo "DONE!"
