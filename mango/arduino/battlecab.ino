#include <SoftwareSerial.h>

#define rxPin 3  
#define txPin 4  
#define shoot_btn 5
#define heal_btn 6
#define rgb_r 7
#define rgb_g 8
#define rgb_b 9
int freq = 9600;
char cab[10] = ""; // the cab itself. must be unique in network.
char msg[100] = "";
char nick[32] = "battlecab"; // the player nick.
int shots = 0;
int heals = 0;
int lvl = 0;
int hp = 0;
int ac = 0;


SoftwareSerial irTx =  SoftwareSerial(rxPin, txPin);

void setup()  
{
  pinMode(rgb_r, OUTPUT);
  pinMode(rgb_g, OUTPUT);
  pinMode(rgb_b, OUTPUT);
  pinMode(shoot_btn,INPUT_PULLUP);
  pinMode(heal_btn, INPUT_PULLUP);
  XSERIAL.begin(freq);
  Serial.begin(freq);
  Serial.println("OK");
}
void trigger_in(m) {
  msg += "<";
  msg += cab;
  msg += ":"
  msg += mode;
  msg += ":";
  msg += nick;
  msg += ":";
  msg += hp * lvl;
  msg += "/";
  msg += ac;
  msg += " ";
  msg += m;
  irTx.println(msg);
  msg = "";
}
void trigger_out(m)
{
  if (m == 0) && shots > 0 ) || (m == 1) && (heals > 0) {
    msg += ">";
    msg += cab;
    msg += ":";
    msg += m;
    msg += ":";
    msg += nick;
    msg += ":";
    msg += hp * lvl;
    msg += "/";
    msg += ac;
    irTx.println(msg);
    msg = "";
}
void loop() 
{
  shootState = digitalRead(shoot_btn);
  healState = digitalRead(heal_btn);
  if (shootState == HIGH) {
    trigger_out(0);
  } else if (healState == HIGH) {
    trigger_out(1);
  } else if (irTx.available()) {
    while (irTx.available()) {
      a = (char)irTx.readString();
      trigger_in(a);
      Serial.println(a);
    }
  } else if (Serial.available()) {
    while (Serial.available()) {
      a = Serial.readString;
      // store nick/team/shots/heals/etc...
    }
  }
}
