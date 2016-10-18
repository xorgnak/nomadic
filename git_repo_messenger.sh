GIT_USER=`git config --global user.name`
function messenger() {
    echo "c <topic> <msg> - Send <msg> to <ch>"
    echo "r <topic> - Read <topic>"
    echo "f - Fetch Updates"
    echo "t - List Topics"
}
function msg() {
    ch=$1; shift
    echo "$*" > $ch.msg
    git add .
    git commit -m "$GIT_USER `date`"
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
alias c='msg'
alias f='fetch'
alias r='read'
alias t="topics"
