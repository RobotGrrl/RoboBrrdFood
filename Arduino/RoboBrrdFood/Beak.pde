
void rapidOpen(int n) {
	
	mouth.attach(8);
	
	// rough starting points
	// (tricky to figure out)
	int overbite = 0;
	int underbite = 40;
	
	for(int j=0; j<n; j++) {
		
		for(int i=overbite; i<underbite; i++) {
			mouth.write(i);
			delay(10); // smooths out b/w steps
		}
		
		delay(100); // how wide open it goes
		
		for(int i=underbite; i>overbite; i--) {
			mouth.write(i);
			delay(10);
		}
		
		delay(100);
		
	}
	
	mouth.detach();
	
	delay(50);
	
}

void trigger() {
	triggerFlag = true;
}

byte nextByte() {
	while(1) {
		if(Serial.available() > 0) {
			byte b = Serial1.read();
			//if(debug) Serial << "Received byte: " << b << endl;
			return b;
		}
        
        
        if(commAttemptCount >= 100) {
			commAttemptCount = 0;
			break;
		}
		
		commAttemptCount++;
        
		//if(debug) Serial << "Waiting for next byte" << endl;
	}
	
}


// Example of sending data to the comm. board
// Originally used in MANOI
void periodicSend() {
    
    // Send some data to the communication board
    if(second()%30 == 0 || second()%60 == 0) {
        
        //digitalWrite(STATUS, LOW);
        
        //digitalWrite(LED, HIGH);
        delay(500);
        //digitalWrite(LED, LOW);
        
        // Signal that we want to send data
        digitalWrite(interruptOutgoing, HIGH);
        
        while(!triggerFlag) {
            // Waiting for trigger to send the data
            if(debug) Serial << "Waiting for the trigger" << endl;
            //digitalWrite(LED, HIGH);
            delay(50);
            //digitalWrite(LED, LOW);
            delay(50);
            // TODO: Make it give up at some point
            
            if(triggerAttemptCount >= 100) {
                triggerAttemptCount = 0;
                break;
            }
            
            triggerAttemptCount++;
            
        }
        
        // Ready to send data
        if(triggerFlag) {
            
            if(debug) Serial << "Going to send the message now" << endl;
            
            Serial1 << "E*";
            
            //digitalWrite(LED, HIGH);
            delay(1000);
            //digitalWrite(LED, LOW);
            
        }
        
        digitalWrite(interruptOutgoing, LOW);
        triggerFlag = false;
        
    }
    
}

void sensorReadings() {
    int pirReading = analogRead(pir);
    int tiltFBReading = analogRead(tiltFB);
    int tiltLRReading = analogRead(tiltLR);
    int ldrLReading = analogRead(ldrL);
    int ldrRReading = analogRead(ldrR);
    
    if(false) {
        Serial << " PIR: " << pirReading;
        Serial << " TiltFB: " << tiltFBReading;
        Serial << " TiltLR: " << tiltLRReading;
        Serial << " LDR L: " << ldrLReading;
        Serial << " LDR R: " << ldrRReading;
        Serial << endl;
    }
}

void passiveWingsBehaviour() {
    
    int curL = leftwing.read();
    int curR = rightwing.read();
    
    for(int i=0; i<5; i++) {
        leftwing.write(leftwing.read()+1);
        rightwing.write(rightwing.read()+1);
        delay(50);
    }
    
    for(int i=0; i<5; i++) {
        leftwing.write(leftwing.read()-1);
        rightwing.write(rightwing.read()-1);
        delay(50);
    }
    
    leftwing.write(curL);
    rightwing.write(curR);
    
}

void passiveLeftWingWave() {
    
    int curL = leftwing.read();
    
    for(int j=0; j<2; j++) {
        for(int i=60; i<80; i++) {
            leftwing.write(i);
            delay(20);
        }
        for(int i=80; i>60; i--) {
            leftwing.write(i);
            delay(20);
        }
    }
	
    //leftwing.write(curL);
    
}

void passiveRightWingWave() {
    
    int curR = rightwing.read();
    
    for(int j=0; j<2; j++) {
        for(int i=0; i<20; i++) {
            rightwing.write(i);
            delay(20);
        }
        for(int i=20; i>0; i--) {
            rightwing.write(i);
            delay(20);
        }
    }
    
    //rightwing.write(curR);
    
}

void passiveDownLook() {
    
    int curU = updown.read();
    
    if(curU >= 100) return; 
    
    for(int i=curU; i<100; i++) {
        updown.write(i);
        delay(30);
    }
    
    /*
	 for(int i=110; i>curU; i--) {
	 updown.write(i);
	 delay(5);
	 }
     */
    
}

void passiveUpLook() {
    
    int curU = updown.read();
    
    if(curU <= 90) return;
    
    for(int i=curU; i>90; i--) {
        updown.write(i);
        delay(30);
    }
    
    /*
	 for(int i=90; i<curU; i++) {
	 updown.write(i);
	 delay(10);
	 }
     */
    
}

void passiveLeftLook() {
    
    int curL = leftright.read();
    
    if(curL < 70) return;
    
    for(int i=curL; i>70; i--) {
        leftright.write(i);
        delay(10);
    }
    
}

void passiveRightLook() {
    
    int curR = leftright.read();
    
    if(curR > 110) return;
    
    for(int i=curR; i<110; i++) {
        leftright.write(i);
        delay(10);
    }
    
}

void partyBehaviour() {
    
    playTone((int)random(20,175), (int)random(70, 150));
    updateLights(true);
    updateLights(false);
    
}

void ldrBehaviour(int ldrL, int ldrR) {
    
	int current = leftright.read();
	
	if(ldrL < (ldrR+thresh) && ldrL > (ldrR-thresh)) {
        // neutral
		
		if(current < 90) {
			leftright.write(current+1);
		} else if(current > 90) {
			leftright.write(current-1);
		}
        
    } else if(ldrL > (ldrR+thresh)) {
        // left (but go to the right)
		sendToComm('R');
		
		if(current < 180) {
			leftright.write(current+1); // going towards 180
		} else {
			for(int i=0; i<6; i++) {
				moveRightWing(!alternate);
				alternate = !alternate;
				delay(80);
			}
			rightwing.write(20);
		}

    } else if(ldrL < (ldrR-thresh)) {
        // right
		sendToComm('L');
		
		if(current > 0) {
			leftright.write(current-1); // going towards 0
		} else {
			for(int i=0; i<6; i++) {
				moveLeftWing(!alternate);
				alternate = !alternate;
				delay(80);
			}
			leftwing.write(90);
		}
        
    }
	
	current = leftright.read();

	
	if(current < 90) {
		int c0 = 90-current;
		int c1 = (20*c0)/90;
		int c2 = 100-c1;
		updown.write(c2);
	} else if(current > 90) {
		int c0 = 90-(180-current);
		int c1 = (20*c0)/90;
		int c2 = 100-c1;
		updown.write(c2);
	} else {
		updown.write(100);
	}
	
	delay(10);
	
	/*
    if(ldrL < (ldrR+thresh) && ldrL > (ldrR-thresh)) {
        
        // neutral
        
        if(ldrStable >= 5000) {
            moveUpDown(100, 50);
            goMiddle();
            ldrStable = 0;
        }
        
        ldrStable++;
        
    } else if(ldrL > (ldrR+thresh)) {
        // left (but go to the right)
        updown.write(80);
        if(currentDir != 1) goMiddle(); 
        sendToComm('R');
        moveUpDown(80, 50);
        goRight();
        for(int i=0; i<6; i++) {
            moveRightWing(!alternate);
            alternate = !alternate;
            delay(80);
        }
        rightwing.write(20);
        ldrStable = 0;
    } else if(ldrL < (ldrR-thresh)) {
        // right
        if(currentDir != 1) goMiddle(); 
        sendToComm('L');
        moveUpDown(80, 50);
        goLeft();
        for(int i=0; i<6; i++) {
            moveLeftWing(!alternate);
            alternate = !alternate;
            delay(80);
        }
        leftwing.write(90);
        ldrStable = 0;
        
    }
	 */
    
}

void peekABooBehaviour(int ldrL, int ldrR) {
    
    if(ldrL <= (ldrLprev-50) || ldrR <= (ldrRprev-50)) {
        
        // dim the lights
        L1R = 255;//int(random(50, 255));
        L1G = 255;//int(random(50, 255));
        L1B = 255;//int(random(50, 255));
        R1R = L1R;//int(random(50, 255));
        R1G = L1G;//int(random(50, 255));
        R1B = L1B;//int(random(50, 255));
        L2R = int(random(50, 255));
        L2G = int(random(50, 255));
        L2B = int(random(50, 255));
        R2R = int(random(50, 255));
        R2G = int(random(50, 255));
        R2B = int(random(50, 255));
		
        fade( preL1R,    preL1G,      preL1B,  // L1 Start
             L1R,       L1G,         L1B,     // L1 Finish
             preR1R,    preR1G,      preR1B,  // R1 Start
             R1R,       R1G,         R1B,     // R1 Finish
             preL2R,    preL2G,      preL2B,  // L2 Start
             L2R,       L2G,         L2B,     // L2 Finish
             preR2R,    preR2G,      preR2B,  // R2 Start
             R2R,       R2G,         R2B,     // R2 Finish
             1);
		
        preL1R = L1R;
        preL1G = L1G;
        preL1B = L1B;
        preR1R = R1R;
        preR1G = R1G;
        preR1B = R1B;
        preL2R = L2R;
        preL2G = L2G;
        preL2B = L2B;
        preR2R = R2R;
        preR2G = R2G;
        preR2B = R2B;
        
        
        // wiggle the wings
        for(int i=0; i<6; i++) {
            moveLeftWing(alternate);
            moveRightWing(!alternate);
            alternate = !alternate;
            delay(150);
        }
        
        // bright lights
        L1R = 0;//int(random(50, 255));
        L1G = 0;//int(random(50, 255));
        L1B = 0;//int(random(50, 255));
        R1R = L1R;//int(random(50, 255));
        R1G = L1G;//int(random(50, 255));
        R1B = L1B;//int(random(50, 255));
        L2R = int(random(50, 255));
        L2G = int(random(50, 255));
        L2B = int(random(50, 255));
        R2R = int(random(50, 255));
        R2G = int(random(50, 255));
        R2B = int(random(50, 255));
        
        fade( preL1R,    preL1G,      preL1B,  // L1 Start
             L1R,       L1G,         L1B,     // L1 Finish
             preR1R,    preR1G,      preR1B,  // R1 Start
             R1R,       R1G,         R1B,     // R1 Finish
             preL2R,    preL2G,      preL2B,  // L2 Start
             L2R,       L2G,         L2B,     // L2 Finish
             preR2R,    preR2G,      preR2B,  // R2 Start
             R2R,       R2G,         R2B,     // R2 Finish
             1);
        
        preL1R = L1R;
        preL1G = L1G;
        preL1B = L1B;
        preR1R = R1R;
        preR1G = R1G;
        preR1B = R1B;
        preL2R = L2R;
        preL2G = L2G;
        preL2B = L2B;
        preR2R = R2R;
        preR2G = R2G;
        preR2B = R2B;
        
        // play music
        for(int i=0; i<3; i++) {
            playTone((int)random(100,200), (int)random(50, 200));
            delay(50);
        }
		
        // home
        updateLights(true);
        rightwing.write(20);
        leftwing.write(90);
        
    }
    
    ldrLprev = ldrL;
    ldrRprev = ldrR;
    
}

void pirBehaviour(int pirR) {
    
    if(pirR >= 500) {
        
        sendToComm('P');
        
        if(pirCount % 5 == 0) {
            
            //digitalWrite(flagPin, HIGH);
            openBeak();
            delay(100);
            randomChirp();
            //delay(1500);
            underbiteCloseBeak();
            delay(100);
            //digitalWrite(flagPin, LOW);
            
        } else {
            
            for(int i=0; i<6; i++) {
				moveLeftWing(alternate);
				moveRightWing(!alternate);
				alternate = !alternate;
				delay(150);
            }
            rightwing.write(20);
            leftwing.write(90);
            
        }
		
        pirCount++;
        
    }/* else {
	  pirCount = 1; 
	  }
	  */
    //Serial << "PIR Count: " << pirCount << endl;
    
}

void sendToComm(char c) {
    
    digitalWrite(interruptOutgoing, HIGH);
    
    while(!triggerFlag) {
        // Waiting for trigger to send the data
        if(debug) Serial << "Waiting for the trigger" << endl;
        //digitalWrite(LED, HIGH);
        //delay(50);
        //digitalWrite(LED, LOW);
        //delay(50);
        
        if(triggerAttemptCount >= 100) {
            triggerAttemptCount = 0;
            break;
        }
        
        triggerAttemptCount++;
        
    }
    
    // Ready to send data
    if(triggerFlag) {
        
        if(debug) Serial << "Going to send the message now" << endl;
        
        Serial1 << c << "*";
        
        //digitalWrite(LED, HIGH);
        //delay(1000);
        //digitalWrite(LED, LOW);
        
    }
    
    digitalWrite(interruptOutgoing, LOW);
    triggerFlag = false;
    
}

void sendPToComm() {
    
    digitalWrite(interruptOutgoing, HIGH);
    
    while(!triggerFlag) {
        // Waiting for trigger to send the data
        if(debug) Serial << "Waiting for the trigger" << endl;
        //digitalWrite(LED, HIGH);
        delay(50);
        //digitalWrite(LED, LOW);
        delay(50);
        // TODO: Make it give up at some point
        
        if(triggerAttemptCount >= 100) {
            triggerAttemptCount = 0;
            break;
        }
        
        triggerAttemptCount++;
        
    }
    
    // Ready to send data
    if(triggerFlag) {
        
        if(debug) Serial << "Going to send the message now" << endl;
        
        Serial1 << "P*";
        
        //digitalWrite(LED, HIGH);
        delay(1000);
        //digitalWrite(LED, LOW);
        
    }
    
    digitalWrite(interruptOutgoing, LOW);
    triggerFlag = false;
    
}

void updateLights(boolean independent) {
    
	//    fade( preL1R,    preL1G,      preL1B,  // L1 Start
	//         256,       256,         256,     // L1 Finish
	//         preR1R,    preR1G,      preR1B,  // R1 Start
	//         256,       256,         256,     // R1 Finish
	//         preL2R,    preL2G,      preL2B,  // L2 Start
	//         L2R,       L2G,         L2B,     // L2 Finish
	//         preR2R,    preR2G,      preR2B,  // R2 Start
	//         R2R,       R2G,         R2B,     // R2 Finish
	//         1);
    
	//    analogWrite(redR, HIGH);
	//    analogWrite(greenR, HIGH);
	//    analogWrite(blueR, HIGH);
	//    analogWrite(redL, LOW);
	//    analogWrite(greenL, LOW);
	//    analogWrite(blueL, LOW);
	//    
	//    delay(500);
	//    
	//    preL1R = 0;
	//    preL1G = 0;
	//    preL1B = 0;
	//    preR1R = 0;
	//    preR1G = 0;
	//    preR1B = 0;
    if(independent) {
        
        L1R = int(random(50, 255));
        L1G = int(random(50, 255));
        L1B = int(random(50, 255));
        R1R = int(random(50, 255));
        R1G = int(random(50, 255));
        R1B = int(random(50, 255));
        L2R = int(random(50, 255));
        L2G = int(random(50, 255));
        L2B = int(random(50, 255));
        R2R = int(random(50, 255));
        R2G = int(random(50, 255));
        R2B = int(random(50, 255));
        
    } else {
		
		
        L1R = int(random(50, 255));
        L1G = int(random(50, 255));
        L1B = int(random(50, 255));
		R1R = L1R;//int(random(50, 255));
		R1G = L1G;//int(random(50, 255));
		R1B = L1B;//int(random(50, 255));
        L2R = int(random(50, 255));
        L2G = int(random(50, 255));
        L2B = int(random(50, 255));
        R2R = int(random(50, 255));
        R2G = int(random(50, 255));
        R2B = int(random(50, 255));
        
    }
	
	fade( preL1R,    preL1G,      preL1B,  // L1 Start
		 L1R,       L1G,         L1B,     // L1 Finish
		 preR1R,    preR1G,      preR1B,  // R1 Start
		 R1R,       R1G,         R1B,     // R1 Finish
		 preL2R,    preL2G,      preL2B,  // L2 Start
		 L2R,       L2G,         L2B,     // L2 Finish
		 preR2R,    preR2G,      preR2B,  // R2 Start
		 R2R,       R2G,         R2B,     // R2 Finish
		 1);
	
	preL1R = L1R;
	preL1G = L1G;
	preL1B = L1B;
	preR1R = R1R;
	preR1G = R1G;
	preR1B = R1B;
	preL2R = L2R;
	preL2G = L2G;
	preL2B = L2B;
	preR2R = R2R;
	preR2G = R2G;
	preR2B = R2B;
    
}


void fade ( int startL1_R,  int startL1_G,  int startL1_B, 
		   int finishL1_R, int finishL1_G, int finishL1_B,
		   int startR1_R,  int startR1_G,  int startR1_B,
		   int finishR1_R, int finishR1_G, int finishR1_B,
		   int startL2_R,  int startL2_G,  int startL2_B, 
		   int finishL2_R, int finishL2_G, int finishL2_B,
		   int startR2_R,  int startR2_G,  int startR2_B,
		   int finishR2_R, int finishR2_G, int finishR2_B,
		   int stepTime ) {
    
    int skipEveryL1_R = 256/abs(startL1_R-finishL1_R); 
    int skipEveryL1_G = 256/abs(startL1_G-finishL1_G);
    int skipEveryL1_B = 256/abs(startL1_B-finishL1_B); 
    int skipEveryR1_R = 256/abs(startR1_R-finishR1_R); 
    int skipEveryR1_G = 256/abs(startR1_G-finishR1_G);
    int skipEveryR1_B = 256/abs(startR1_B-finishR1_B); 
    int skipEveryL2_R = 256/abs(startL2_R-finishL2_R); 
    int skipEveryL2_G = 256/abs(startL2_G-finishL2_G);
    int skipEveryL2_B = 256/abs(startL2_B-finishL2_B); 
    int skipEveryR2_R = 256/abs(startR2_R-finishR2_R); 
    int skipEveryR2_G = 256/abs(startR2_G-finishR2_G);
    int skipEveryR2_B = 256/abs(startR2_B-finishR2_B); 
    
    for(int i=0; i<256; i++) {
        
        if(startL1_R<finishL1_R) {
            if(i<=finishL1_R) {
                if(i%skipEveryL1_R == 0) {
                    analogWrite(redL, i);
                } 
            }
        } else if(startL1_R>finishL1_R) {
            if(i>=(256-startL1_R)) {
                if(i%skipEveryL1_R == 0) {
                    analogWrite(redL, 256-i); 
                }
            } 
        }
        
        if(startL1_G<finishL1_G) {
            if(i<=finishL1_G) {
                if(i%skipEveryL1_G == 0) {
                    analogWrite(greenL, i);
                } 
            }
        } else if(startL1_G>finishL1_G) {
            if(i>=(256-startL1_G)) {
                if(i%skipEveryL1_G == 0) {
                    analogWrite(greenL, 256-i); 
                }
            } 
        }
        
        if(startL1_B<finishL1_B) {
            if(i<=finishL1_B) {
                if(i%skipEveryL1_B == 0) {
                    analogWrite(blueL, i);
                } 
            }
        } else if(startL1_B>finishL1_B) {
            if(i>=(256-startL1_B)) {
                if(i%skipEveryL1_B == 0) {
                    analogWrite(blueL, 256-i); 
                }
            } 
        }
        
        if(startR1_R<finishR1_R) {
            if(i<=finishR1_R) {
                if(i%skipEveryR1_R == 0) {
                    analogWrite(redR, i);
                } 
            }
        } else if(startR1_R>finishR1_R) {
            if(i>=(256-startR1_R)) {
                if(i%skipEveryR1_R == 0) {
                    analogWrite(redR, 256-i); 
                }
            } 
        }
        
        if(startR1_G<finishR1_G) {
            if(i<=finishR1_G) {
                if(i%skipEveryR1_G == 0) {
                    analogWrite(greenR, i);
                } 
            }
        } else if(startR1_G>finishR1_G) {
            if(i>=(256-startR1_G)) {
                if(i%skipEveryR1_G == 0) {
                    analogWrite(greenR, 256-i); 
                }
            } 
        }
        
        if(startR1_B<finishR1_B) {
            if(i<=finishR1_B) {
                if(i%skipEveryR1_B == 0) {
                    analogWrite(blueR, i);
                } 
            }
        } else if(startR1_B>finishR1_B) {
            if(i>=(256-startR1_B)) {
                if(i%skipEveryR1_B == 0) {
                    analogWrite(blueR, 256-i); 
                }
            } 
        }
        
        delay(stepTime);
        
    }
    
}

void randomChirp() {
    for(int i=0; i<10; i++) {
        playTone((int)random(100,800), (int)random(50, 200));
    }
}


void playTone(int tone, int duration) {
	
	for (long i = 0; i < duration * 1000L; i += tone * 2) {
		digitalWrite(spkr, HIGH);
		delayMicroseconds(tone);
		digitalWrite(spkr, LOW);
		delayMicroseconds(tone);
	}
	
}

void moveBeak(int destination, int stepDelay, int doneDelay) {
	
	mouth.attach(8);
	
	int current = mouth.read();
	
	if(current > destination) {
		
		for(int i=current; i>destination; i--) {
			mouth.write(i);
			delay(stepDelay);
		}
		
	} else if(current < destination) {
		
		for(int i=current; i<destination; i++) {
			mouth.write(i);
			delay(stepDelay);
		}
		
	}
	
	mouth.detach();
	delay(doneDelay);
	
}

void openBeak() {
	int stepDelay = 10;
	int doneDelay = 50;
	moveBeak(90, stepDelay, doneDelay);
}

void underbiteCloseBeak() {	
	int stepDelay = 10;
	int doneDelay = 50;
	moveBeak(0, stepDelay, doneDelay);
}

void overbiteCloseBeak() {
	int stepDelay = 10;
	int doneDelay = 50;
	moveBeak(180, stepDelay, doneDelay);
}


void peck() {
	moveBeak(10, 5, 50);
	moveBeak(30, 5, 50);
}

void randomBeak() {
	moveBeak((int)random(0, 180), 5, 50);
}

