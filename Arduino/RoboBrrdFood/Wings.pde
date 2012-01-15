
void moveLeftWing(boolean goUp) {
  
  int up = 60; // 60
  int down = 120; // 0
  
  if(goUp) {
  
  for(int i=up; i<down; i++) {
    leftwing.write(i);
    //delay(100);
  }
  
  } else {
  
  for(int i=down; i>up; i--) {
    leftwing.write(i);
    //delay(100);
  }
  
  }
  
}

void moveRightWing(boolean goUp) {
  
  int up = 0;
  int down = 60;
  
  if(!goUp) {
  
  for(int i=up; i<down; i++) {
    rightwing.write(i);
    //delay(200);
    //Serial << i << endl;
  }
  
  } else {
  
  for(int i=down; i>up; i--) {
    rightwing.write(i);
    //delay(200);
    //Serial << i << endl;
  }
  
  }
  
}

