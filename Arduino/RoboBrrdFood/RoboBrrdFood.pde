/*
ROBOBRRD FOOOOOD!
*/


#include <Time.h>
#include <Servo.h> 
#include <Streaming.h>

boolean debug = false;

// Servos
Servo mouth, leftwing, rightwing, leftright, updown;

// Sensors
int pir(A0), tiltFB(1), tiltLR(2), ldrL(3), ldrR(4);

// Servo pins
int mouthPin(8), leftwingPin(7), rightwingPin(6);
int leftrightPin(5), updownPin(4);

// LED pins
int redR(3), greenR(9), blueR(10);
int redL(11), greenL(12), blueL(13);

// LED Values
int L1R = 255;
int L1G = 255;
int L1B = 255;
int R1R = 255;
int R1G = 255;
int R1B = 255;
int L2R = 255;
int L2G = 255;
int L2B = 255;
int R2R = 255;
int R2G = 255;
int R2B = 255;
int preL1R = 0;
int preL1G = 0;
int preL1B = 255;
int preR1R = 0;
int preR1G = 0;
int preR1B = 255;
int preL2R = 0;
int preL2G = 0;
int preL2B = 255;
int preR2R = 0;
int preR2G = 0;
int preR2B = 255;

// Misc.
boolean alternate = true;
int pirCount = 1;
int thresh = 50;
int ldrStable = 0;
int currentDir = 1;
int ldrLprev = 0;
int ldrRprev = 0;

// All the pins
int interruptIncomming = 0; // on pin 2
int interruptOutgoing = 22;

// Counters
int triggerAttemptCount = 0;
int commAttemptCount = 0;

// Trigger flag
volatile boolean triggerFlag = false;

int pos = 0;

int flagPin = 24;

int spkr = 26;


#define LENGTH 2

int rxBuffer[128]; 
int rxIndex  = 0;    

boolean serialMessages = false;

void setup() {
  
  // Communication
	Serial.begin(9600);
    Serial1.begin(9600);
    Serial2.begin(9600);
	
	// Interrupts
	pinMode(interruptOutgoing, OUTPUT);
    digitalWrite(interruptOutgoing, LOW);
    
	attachInterrupt(interruptIncomming, trigger, RISING);
	digitalWrite(2, LOW);
    
    pinMode(flagPin, OUTPUT);
    digitalWrite(flagPin, LOW);
    
    pinMode(spkr, OUTPUT);
    
    // LEDs
    pinMode(redR, OUTPUT);
    pinMode(greenR, OUTPUT);
    pinMode(blueR, OUTPUT);
    pinMode(redL, OUTPUT);
    pinMode(greenL, OUTPUT);
    pinMode(blueL, OUTPUT);
    
    // Sensors
    pinMode(pir, INPUT);
    pinMode(tiltFB, INPUT);
    pinMode(tiltLR, INPUT);
    pinMode(ldrL, INPUT);
    pinMode(ldrR, INPUT);
    
    // Servos
    leftwing.attach(leftwingPin);
    rightwing.attach(rightwingPin);
    leftright.attach(leftrightPin);
    updown.attach(updownPin);
    
    // Home positions
    leftwing.write(90);
    rightwing.write(20);
    leftright.write(90);
    updown.write(95);
    
    rightwing.write(20);
    leftwing.write(90);
    moveBeak(180, 2, 10);
  
}

void loop (){
 
 if (Serial2.available() > 0) {

   rxBuffer[rxIndex++] = Serial2.read();
   
   if (rxIndex == LENGTH) {
     
     int food = (int)rxBuffer[0];
     int val = (int)rxBuffer[1];
      
      Serial << "food: " << food << " val " << val << endl;
      
      if(food > 0) { // 1
       
        if(val == 2) {
          
          for(int i=0; i<3; i++) {
	    moveBeak(90, 2, 10);
            moveBeak(180, 2, 10);
          }
          
        } else if(val == 1) {
          
          for(int i=0; i<5; i++) {
            moveLeftWing(!alternate);
            moveRightWing(alternate);
            alternate = !alternate;
            delay(80);
          }
          
          leftwing.write(90);
          rightwing.write(20);
          
        }
        
      }
       
      rxIndex = 0;
   }
 }
 delay(10);

}



