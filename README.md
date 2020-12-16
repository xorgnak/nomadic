[![made-with-ruby](https://img.shields.io/badge/Made%20with-Ruby-1f425f.svg)](https://rubylang.org/)
[![made-with-bash](https://img.shields.io/badge/Made%20with-Bash-1f425f.svg)](https://www.gnu.org/software/bash/)
[![made-with-javascript](https://img.shields.io/badge/Made%20with-Javascript-1f425f.svg)](https://www.javascript.com)
[![Open Source Love png2](https://badges.frapsoft.com/os/v2/open-source.png?v=103)](https://github.com/ellerbrock/open-source-badges/)
### Installation
1. get linux running.
1. get git running.
1. clone nomadic.
1. run `cd nomadic && ./run`


<svg fill="none" viewBox="0 0 120 120" width="120" height="120" xmlns="http://www.w3.org/2000/svg">
  <foreignObject width="100%" height="100%">
    <div xmlns="http://www.w3.org/1999/xhtml">
      <style>
@keyframes bounce {
  0%   { transform: scale(1,    1)   translateY(0)     skew(0deg,  0deg); }
  3%   { transform: scale(1,    1)   translateY(0)     skew(0deg,  0deg); }
  5%   { transform: scale(1.1,  .9)  translateY(5px)   skew(0deg,  0deg); }
  12%  { transform: scale(.9,   1.1) translateY(-70px) skew(25deg, 5deg); }
  13%  { transform: scale(.9,   1.1) translateY(-70px) skew(25deg, 5deg); }
  20%  { transform: scale(1.05, .95) translateY(0)     skew(0deg,  0deg); }
  22%  { transform: scale(1,    1)   translateY(-7px)  skew(0deg,  0deg); }
  27%  { transform: scale(1,    1)   translateY(0)     skew(0deg,  0deg); }
  100% { transform: scale(1,    1)   translateY(0)     skew(0deg,  0deg); }
}
h1 {
  width: 120px;
  line-height: 20px;
  padding-top: 70px;
  text-align: center;
  font: 400 16px/1.5 Helvetica ,Arial ,sans-serif;
  color: rgb(52, 73, 94);
  transform-origin: bottom;
  animation: 4s cubic-bezier(.5, 0, .5, 1.2) 1s infinite bounce;
}
      </style>
      <h1>Hello, world</h1>
    </div>
  </foreignObject>
</svg>


<div><script data-name="BMC-Widget" src="https://cdnjs.buymeacoffee.com/1.0.0/widget.prod.min.js" data-id="maxcatman" data-description="Support me on Buy me a coffee!" data-message="Good software takes a lot of late night hours.  Support the cause with lots of fresh hot coffee!" data-color="#FFDD00" data-position="Right" data-x_margin="18" data-y_margin="18"></script></div>


### How it works
Nomadic linux provides a set of organizational tools which take advantage of local, IoT, and cloud resources.  The web interface provides a simple way to use the tools to get things done and more.  

#### High Level
Nomadic runs a webserver to provide interfacing to the tools provided.  The menu provodes other interfaces can be opened to provide bilboarding and customer impact functions as well as other useful tools.  

#### Lox level
After the web app loads, all further communications from and to the browser pass across an mqtt networks.  Services listen to mqtt traffic and push their results to the browser across the same network.  This provides a lightweight single layer communications protocol capable of managing a user's state across all interfaces in real time.  

### Usage
Nomadic is made up of two tools which provide access to the local nomadic services.
#### app server
```
usage: ./cabage/now [quiet] [local]
```
#### shell helper
```
usage: ./cabage/work <option> [arg]
```
### Project Info
About the project...
#### Use cases
what is this for anyways?
##### a personal computer
it's linux folks.  Adding Nomadic to your Debian based linux installation will give you a solid set of tools useful for general computing as well as development.
##### a business pos and bilboard display
Nomadic is designed to allow you to use any display as a marketing tool for your brand.  The customer interaction interface also functions as a simple point of sale system, prompting your customer with an invoice and button to pay via venmo.
##### for school
Nomadic makes heavy use of the org-mode note taking system built into the emacs text editor.  It allows free form notes to contain formulas, lists, and tables.  Further information can be found [here](https://org-mode.org).
##### for kids
Nomadic does waste muct time or space with games, but it does ship with an nes emulator and a mush server.

### stats
####
[![1](https://github-readme-stats.vercel.app/api?username=xorgnak&theme=radical&show_icons=true&layout=compact)](https://github.com/xorgnak/nomadic)
#### 
![1](https://github-readme-stats.vercel.app/api/top-langs/?username=xorgnak&theme=radical&layout=compact)
