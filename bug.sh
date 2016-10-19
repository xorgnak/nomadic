
SERVER='irc.freenode.net'
NICK='xorgwomp'
CHANNEL='#bord'
EMAIL='xorgnak@gmail.com'

function bug_report() {
    DIR=~/.bugs
    if [[ $1 == '--die' ]]; then
	pkill ii
	pkill tail
	echo "Dead."
    else
	i=`pgrep ii`
	if [[ $i == '' ]]; then
	    echo "Connecting..."
	    ii -i $DIR -s $SERVER -n $NICK &
	    sleep 2
	    echo "Joining..."
	    sleep 8
	    echo -e "/j $CHANNEL" >> $DIR/$SERVER/in
	fi
	echo "Ready!"
	echo "What were you doing?"
	read -p '> ' action
	echo "What did you expect?"
	read -p '> ' expectation
	echo "What happened?"
	read -p '> ' result
	o="$EMAIL A: $action; E: $expectation; R: $result;"
	echo $o >> $DIR/$SERVER/$CHANNEL/in
	if [[ $1 == '--client' ]]; then
	    :> $DIR/$SERVER/$CHANNEL/out
	    tail -f $DIR/$SERVER/$CHANNEL/out &
	    export t=$!
	    while true
	    do
		trap "echo 'OUT' >> $DIR/$SERVER/$CHANNEL/in && kill -9 $t && break" INT
		read -p "[ $CHANNEL ]> " x
		echo "$x" >> $DIR/$SERVER/$CHANNEL/in
	    done
	else
	    echo "Reported."
	fi
    fi
}
alias bug='bug_report'
