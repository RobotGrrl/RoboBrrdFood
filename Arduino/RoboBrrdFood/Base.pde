
void goLeft() {
  
  int currentPos = leftright.read();
  int dee = 10;
  
  for(int i=currentPos; i>0; i--) {
    leftright.write(i);
    delay(dee);
  }
  
  currentDir = 0;
  
}

void goRight() {
  
  int currentPos = leftright.read();
  int dee = 10;
  
  for(int i=currentPos; i<180; i++) {
    leftright.write(i);
    delay(dee);
  }
  
  currentDir = 2;
  
}

void goMiddle() {
  
  int currentPos = leftright.read();
  int dee = 10;
  
  if(currentPos > 90) {
    
    for(int i=currentPos; i>90; i--) {
      leftright.write(i);
      delay(dee);
    }
    
  } else {
   
   for(int i=currentPos; i<90; i++) {
     leftright.write(i);
     delay(dee);
   }
    
  }
  
  currentDir = 1;
  
}

void leftrightTest() {
 
  int left = 0;
  int right = 180;
  
  for(int i=left; i<right; i++) {
    leftright.write(i);
    delay(100);
  }
  
  for(int i=right; i>left; i--) {
    leftright.write(i);
    delay(100);
  }
  
}

void updownTest(int d) {
 
  int up = 80;
  int down = 105;
  
  for(int i=up; i<down; i++) {
    updown.write(i);
    delay(d);
  }
  
  delay(500);
  
  for(int i=down; i>up; i--) {
    updown.write(i);
    delay(d);
  }
  
}

void moveUpDown(int target, int d) {
  int currentUp = updown.read();
            
            if(currentUp > target) {
                
                for(int i=currentUp; i>target; i--) {
                    updown.write(i);
                    delay(d);
                }
                
            } else {
                
                for(int i=currentUp; i<target; i++) {
                    updown.write(i);
                    delay(d);
                }
                
            }
}

