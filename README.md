# NOMADIC
[![0](https://img.shields.io/badge/Made%20with:-Ruby,%20Bash,%20Javascript,%20C/C++,%20and%20<3!-1f425f.svg)](https://rubylang.org/)
## GET STARTED NOW
1. run the following in any debian/ubuntu based terminal and follow the prompts.
```
git clone https://github.com/xorgnak/nomadic && cd nomadic && ./run
```
2. that's it.  you're done.  Just wait for the installer to finish.
3. Support further development...
# [![Buy Me A Coffee !](https://img.shields.io/badge/buy%20me%20a-coffee-1abc9c.svg)](https://www.buymeacoffee.com/maxcatman) [![Support My Work !](https://img.shields.io/badge/support%20my-work-1abc9c.svg)](https://www.patreon.com/zyphr) [![Visit My Store !](https://img.shields.io/badge/visit%20my-store-1abc9c.svg)](https://www.etsy.com/shop/tomorrowsfuture)
## What it is
- It's linux folks.  Adding Nomadic to your Debian based linux installation will give you a solid set of tools useful for general computing as well as development.
- Nomadic is designed to allow you to use any display as a marketing tool for your brand.  The customer interaction interface also functions as a simple point of sale system, prompting your customer with an invoice and button to pay via venmo.
- Nomadic makes heavy use of the org-mode note taking system built into the emacs text editor.  It allows free form notes to contain formulas, lists, and tables.  Further information can be found [here](https://org-mode.org).
- Nomadic does waste muct time or space with games, but it does ship with an nes emulator and a mush server.

## how it works
Nomadic linux provides a set of organizational tools which take advantage of local, IoT, and cloud resources.  The web interface provides a simple way to use the tools to get things done and more.  
Nomadic runs a webserver to provide interfacing to the tools provided.  The menu provodes other interfaces can be opened to provide bilboarding and customer impact functions as well as other useful tools.  
After the web app loads, all further communications from and to the browser pass across an mqtt networks.  Services listen to mqtt traffic and push their results to the browser across the same network.  This provides a lightweight single layer communications protocol capable of managing a user's state across all interfaces in real time.  

## how you use it
### connecting to wifi
```
./cabage/work wifi
```
### connecting to a server
```
./cabage/work connect <the server you are connecting to> 
```
### watching network traffic
```
./work shark
```
### seeing what your device looks like from the outside
```
./work scanme
```
### watch file creation and publish events
```
./work /path/to/directory
```
### borrow your neighbors wifi
```
./work hack
```
### update cabage
```
./work pull && ./now
```

## quick reference
```
usage: ./work [connect|push|pull|browser|user|wifi|hack|shark|fingerprint|scanme|watch]
 connect <domain>
 push <your commit message>
 pull
 browser
 user <working username>
 wifi
 hack
 shark
 fingerprint <domain>
 scanme
 watch <dir>
```

## app server
This is the server which hosts the web interfaces.  Nomadic will start it when the system starts, but sometimes you may need to start it locally.
```
usage: ./cabage/now [quiet] [local]
 quiet: turns inline debugging off.  Helpfull for using the cabage shell.
 local: runs cabage without ruby virtual machine support.  Helpful for development.
```

## stats
###
[![1](https://github-readme-stats.vercel.app/api?username=xorgnak&theme=radical&show_icons=true&layout=compact)](https://github.com/xorgnak/nomadic)
### 
![1](https://github-readme-stats.vercel.app/api/top-langs/?username=xorgnak&theme=radical&layout=compact)
###
[![Open Source Love png2](https://badges.frapsoft.com/os/v2/open-source.png?v=103)](https://github.com/ellerbrock/open-source-badges/)
