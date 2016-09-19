
class Zone {

  void start() {
    if (DEBUG) println("build zone 4");

    return;
  }

  void draw() {

    offscreen.stroke(255);
    
    myMovie.speed(movieSpeed()); 
    
   float theta = 0;
   //float theta = 0;
  intensity = stressIntensityVal();
  if (stressVal > lastStressVal) {
    myMovie.jump(stressMovieVal[currentZone-1][intensity]);
  } else if (stressVal < lastStressVal || hasCalm) {
    myMovie.jump(stressMovieVal[currentZone-1][4]);
    hasCalm = false;
    // myMovie
  } else {
    //myMovie.jump(stressMovieVal[currentZone-1][intensity] + updateMovieScrub());
  }
  
  lastStressVal = stressVal;

    if (true) {
      //println("framRate " + frameRate);
      offscreen.textSize(15);
      offscreen.text("time " + myMovie.time(), .7 * movX, 0.1 * movY);
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
  
}