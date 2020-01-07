#include <EEPROM.h>
#include <SoftwareSerial.h>
SoftwareSerial mySerial(4, 3); // RX, TX
String data;
String shot = "";
String b;
int baud_usb = 9600; // tty baud setting.
int baud_ir = 9600; // ir baud setting.
int mode = 0;
int lvl;
int spread = 5;
int shot_left = 0;
int shot_count = spread * (lvl + 1);
bool shooting = false;
void setup()
{
  EEPROM.get(0, lvl);
  EEPROM.get(1, data);
  pinMode(12,INPUT);
  pinMode(13, OUTPUT);
  // Open serial communications and wait for port to open:
  Serial.begin(baud_usb);
  while (!Serial) {
    ; // wait for serial port to connect. Needed for Native USB only
  }
  // set the data rate for the SoftwareSerial port
  mySerial.begin(baud_ir);
  Serial.println("OK");
}

void shoot() {
    b += String(mode);
    b += String(":");
    b += String(shot_count);
    b += String(":");
    b += String(shot_left);
    b += String(":");
    b += data;
    b += String(":");
    b += shot;
    b += "\0";
    mySerial.print(b);
      Serial.println(b);
    b = "";
}
void loop() // run over and over
{
  if (digitalRead(12) == HIGH && shot_left == 0 && shooting == false) {
    mode = 1;
    shot_left = shot_count;
  } else {
    shooting = false;
   mode = 0; 
  }
  if (shot_left > 0) {
    mode = 1;
   shot_left--;
  }
  if (mySerial.available()) {
    int availableBytes = mySerial.available();
    for(int i=0; i<availableBytes; i++)
    {
      b += String(mySerial.read());
    }
    mode = 2;
    shot = b;
  }
  if (Serial.available()) {
    int a = Serial.available();
    if (a > 1) {
      data = Serial.readString();
      EEPROM.put(1, data);
    } 
    else 
    { 
      lvl = Serial.read() - '0';
      EEPROM.put(0, lvl);
      shot_count = spread * (lvl + 1);
    }
  }
  shoot();
}


