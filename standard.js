/*
 nomadic standard.
*/

var examples = `// nomadic examples
//
// first, let's talk...
//
// this ain't no chat program for humans!
//
// the "output" variable is what will be
// displayed when your block is run.
//
// the "input" variable is the raw input
// from the broker.
//
// the "input" is broken up into "words".
// output = input;
//
// thr first word if "from" and if it matches
// your "chan", then "state.me" is true.
// output = from;
//
// the second word is the "verb" or action of
// the handler and if it if anything other than 'OK',
// then "state.me" is true.
// output = verb;
//
// the rest of the words are the "nouns", and should be 
// handled by your handler.
// output = nouns;
//
// all of these things have been packaged together in 
// the "state" object mentioned above and are rendered 
// in stringified format with "json".
//
// good luck.
//
// ...and now back to your stuff...
//
output = json;
`;
var db = null; 
var id = null;
function getQueryStringValue (key) {  
  return decodeURIComponent(window.location.search.replace(new RegExp("^(?:.*[&\\?]" + encodeURIComponent(key).replace(/[\.\+\*]/g, "\\$&") + "(?:\\=([^&]*))?)?.*$", "i"), "$1"));  
}
function save() {
    console.log("save", db);
    localStorage.setItem("db", JSON.stringify(db));
}
function load() {                                                            
    db = JSON.parse(localStorage.getItem("db"));
    console.log("load", db);
} 
$(function() {
    var mode = getQueryStringValue("mode");
    console.log("mode", mode);
    var date = new Date();
    $(".i").hide();
    $(".h").hide();
    $(".x").show();                                         
    id = localStorage.getItem("id");      
    console.log("previous session: ", id);                              
    if (id === null || mode === "anonymous") {
        console.log("id created");                                           
        localStorage.setItem("id", Math.random().toString(36).slice(2));
    localStorage.setItem("db", JSON.stringify({"block": "output = input;"})); 
    }                                                                      
    console.log("stored session");                                           
    id = localStorage.getItem("id"); 
    load();
    var broker = "broker.hivemq.com";
    var port = 8000;
    var network = "cabf00d0";
    var chan = network + "/" + id;
    

    
    
    function mqtt_send(s) {
	console.log("mqtt_send", s);
	if ( s == "" || s == null || s == undefined) {
	    ss = "OK"
	} else {
	    ss = s
	}
  message = new Paho.MQTT.Message(chan + " " + ss);
  message.destinationName = chan;
  client.send(message);
}

// Create a client instance
client = new Paho.MQTT.Client(broker, Number(port), id);

// set callback handlers
client.onConnectionLost = onConnectionLost;
client.onMessageArrived = onMessageArrived;

// connect the client
client.connect({onSuccess:onConnect});


// called when the client connects
function onConnect() {
  // Once a connection has been made, make a subscription and send a message.
  console.log("onConnect");
//    client.subscribe(chan);
    client.subscribe(network + "/#");
  mqtt_send("JOIN LIVE");
}

// called when the client loses its connection
function onConnectionLost(responseObject) {
    if (responseObject.errorCode !== 0) {
	console.log("onConnectionLost", responseObject);
	location.reload();
  }
}

// called when a message arrives
    function onMessageArrived(message) {
	var bd = "p"
	var output = "";
	var input = message.payloadString;
	if (input[0] == "{" || input[0] == "[") { var json = JSON.parse(input); }
	var words = input.split(" ");
	var from = words.shift();
	var from_me;
	if (from == chan) { from_me = true; } else { from_me = false; }
	var verb = words.shift();
	var verb_act;
	if (verb == "OK") { verb_act = false; } else { verb_act = true; } 
	var nouns = words;
	var state = {
	    act: verb_act,
	    me: from_me,
	    from: from,
	    input: input,
	    verb: verb,
	    nouns: nouns };
	var json = JSON.stringify(state, null, 2);
	function pipe(s) { db.block = "output = " + s + ";"; }
	load();
	eval(db.block);
	save();
	load();
	$("#output").prepend("<" + bd + ">" + output + "</" + bd + ">");
	console.log("onMessageArrived: ", input, output);
}
    $(document).on('submit', 'form', function(ev) {
	ev.preventDefault();
	$("#send").click();
    });
    $(document).on('click', '#run', function(ev) {
	load();
	$("#do").val(db.block);
	$(".x").hide();
        $(".h").hide();
        $(".i").show();                                          
    });
    $(document).on('click', '#save', function(ev) {
        db.block = $("#do").val();
	save();
        $(".i").hide();                                                      
        $(".h").hide();                                                      
        $(".x").show();                                                      
    });
    $(document).on('click', '#help', function(ev) {
        $(".h").show();
        $("#help").hide();
    });
    $(document).on('click', '#close', function(ev) {
        $(".h").hide();
        $("#help").show();
    });
    $(document).on('click', '#send', function(ev) {
        mqtt_send($("#cmd").val());
	$("#cmd").val("");
    });
    $(document).on('click', '#ex', function(ev) {                      
        var v = examples + "/*" + $("#do").val() + "*/";
        $("#do").val(v);                                                   
    });
});
