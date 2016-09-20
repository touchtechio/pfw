
class Zone4 {

  void start() {
    //if (DEBUG) println("build zone 4");

    return;
  }

  void draw() {

    offscreen.stroke(255);
    
    myMovie.speed(movieSpeed()); 
    
   float theta = 0;
   //float theta = 0;
  intensity = stressIntensityVal();
  if (stressVal > lastStressVal) {
    myMovie.jump(stressMovieVal[currentZone-1][intensity]); // jumps to times, speed changes linearly
  } else if (stressVal < lastStressVal || hasCalm) {
    myMovie.jump(stressMovieVal[currentZone-1][intensity]);
    //myMovie.jump(stressMovieVal[currentZone-1][3]);
    hasCalm = false;
    // myMovie
  } else {
    //myMovie.jump(stressMovieVal[currentZone-1][intensity] + updateMovieScrub());
  }
  
  lastStressVal = stressVal;

    if (true) {
      //println("framRate " + frameRate);
      offscreen.textSize(15);
      offscreen.text("frameRate " + frameRate, .7 * movX, 0.1 * movY);
      displayStressData();
    }
  }
  
  float updateMovieScrub () { // if want to oscillate playing

    //for (int i = 0; i < 20; i++) {
    //return 5 * sin(frameCount%20);
    /*
  theta +=  TWO_PI/36;
     return circleX = 2 * sin(theta);
     */

    //int scale = ((int)millis() % 21);
    float scale = (frameCount % 5);

    if (scale < 5) {
      return (5 - scale);
    }
    return (scale - 4);
  }
  int stressIntensityVal() {
  // maps number of dancers from 1-5 based on stress values
  return (int) map(stressVal, 0, 100, 0, 3);
}

float movieSpeed() {
   return map(stressVal, 0, 100, 0.2, 1.0); 
}

}