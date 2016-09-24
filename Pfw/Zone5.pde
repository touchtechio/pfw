
class Zone5 {

  int intensity;
  int lastIntensity;

  void start() {
    //if (DEBUG) println("build zone 4");
    lastIntensity = -1;
    return;
  }

  void draw() {

    offscreen.stroke(255);

    // myMovie.speed(movieSpeed()); 
    
    //float theta = 0;
    //float theta = 0;
    intensity = stressIntensityVal();
   
    println("stressVal "+stressVal+" lastIntensity "+lastIntensity+" intensity "+intensity);
    if (stressVal > lastStressVal || !hasCalm) {
      myMovie.jump(stressMovieVal[currentZone-1][intensity]);
      lastIntensity = intensity;
      hasCalm = true;
    } else if (stressVal < lastStressVal && lastIntensity < 4 ){// && intensity > 0) { // if stress is decreasing but not to lowest point
      myMovie.jump(stressMovieVal[currentZone-1][lastIntensity + 1]);// (0, 1, 2, 3, 4) need to jump to 3 and 4
      lastIntensity = lastIntensity + 1;
      //if (lastIntensity == 4) {hasCalm = false;}
      // myMovie
    } else {
      
    }
    // if (intensity == 0) hasCalm = false;
    lastStressVal = stressVal;
    

    displayStressData();
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
    return (int) map(stressVal, 0, 101, 0, 3);
  }

  float movieSpeed() {
    return map(stressVal, 0, 100, 0.4, 3.0);
  }
}