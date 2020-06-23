#!/bin/bash

sudo pkill ruby

cd /home/pi/nomadic/mango2

ls -lha

sudo ./mango &

chromium-browser --kiosk localhost &
