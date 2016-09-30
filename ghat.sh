#!/usr/bash
# Tool to automate the topic based development model.
#
# Add this tool to a git source repository to use this tool.
USER=`git config --global user.name`
function msg() {
    ch=$1; shift
    echo "$*" > $ch.msg
    git add .
    git commit -m "$USER `date`"
    git push
}
function fetch() {
    git pull
}
function read() {
    cat $1
}
function topics() {
    ls *.msg
}
fetch
alias c='msg'
alias f='fetch'
alias r='read'
alias t="topics"
echo "# GHAT USAGE"
echo "c <topic> <msg> - Send <msg> to <ch>"
echo "r <topic> - Read <topic>"
echo "f - Fetch Updates"
echo "t - List Topics"
