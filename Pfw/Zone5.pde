
class Zone5 {

  int intensity;
  int lastIntensity;
  int lastStressIntensityVal;
  boolean gettingStressed = false;
  int stressCount = 0;
  float startResetTimer;
  boolean hasCalm;
  boolean turningState;


  void start() {
    //if (DEBUG) println("build zone 4");
    lastIntensity = -1;
    lastStressIntensityVal = -1;
    hasCalm = false;
    turningState = false;
    return;
  }

  void draw() {

    offscreen.stroke(255);

    // myMovie.speed(movieSpeed()); 

    intensity = stressIntensityVal();

    println("lastStressVal "+lastStressIntensityVal+" lastIntensity "+lastIntensity);
    println("turningState" + turningState);
    println("hasCAlmstate" + hasCalm + "stressCOunt " +stressCount);
    checkStressState();
    checkForCalm();
    stateTurn();


    /*
    if (stressIntensityVal() > lastStressIntensityVal || hasCalm) {
     myMovie.jump(stressMovieVal[currentZone-1][intensity]);
     lastIntensity = intensity;
     hasCalm = false;
     } else if (stressIntensityVal() < lastStressIntensityVal && lastIntensity < 5 ) { // if stress is decreasing but not to lowest point
     myMovie.jump(stressMovieVal[currentZone-1][lastIntensity + 1]);// (0, 1, 2, 3, 4) need to jump to 3 and 4
     lastIntensity = lastIntensity + 1;
     if (lastIntensity == 5) hasCalm = true;
     // myMovie
     } else {
     }
     */
    lastStressIntensityVal = stressIntensityVal();
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

  void checkStressState() {
    if (stressIntensityVal() > lastStressIntensityVal || turningState) {

      myMovie.jump(stressMovieVal[currentZone-1][intensity]);
      lastIntensity=intensity;
      stressCount = 0;
      turningState = false;
      return;
    } else if (stressIntensityVal() < lastStressIntensityVal) {

      myMovie.jump(stressMovieVal[currentZone-1][lastIntensity + 1]);// (0, 1, 2, 3, 4) need to jump to 3 and 4
      lastIntensity = lastIntensity + 1;
      stressCount += 1; //begin calming down states, there are 2
      return;
    }
  }

  void checkForCalm() {
    if (stressCount == 2 && !hasCalm) {
      startResetTimer = millis();
      println(startResetTimer);
      hasCalm = true; // start timer once
      return;
    }
  }

  void stateTurn() {
    if (hasCalm) { // only if the timer has been reset
      if (millis() > startResetTimer + 4000) { // 2 seconds after timer starts
        turningState = true;
        hasCalm = false;
        return;
      }
    }
  }
}