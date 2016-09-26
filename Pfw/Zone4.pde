
class Zone4 {

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

    //println("lastStressVal "+lastStressIntensityVal+" lastIntensity "+lastIntensity);
    //println("turningState " + turningState);
    //println("hasCAlmstate " + hasCalm + " stressCount " +stressCount);
    checkStressState();
    //checkForCalm();
    //stateTurn();
    println("time " + myMovie.time());
    keepVideoLoopingInState();

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

  float movieSpeed() {
    return map(stressVal, 0, 100, 0.4, 3.0);
  }

  // compare against last stress value so that scene doesn't keep repeating when new value inputs
  void checkStressState() {
    if (stressIntensityVal() > lastStressIntensityVal) {

      myMovie.jump(stressMovieVal[currentZone-1][intensity]);
      turningState = false;
      return;
    } else if (stressIntensityVal() < lastStressIntensityVal) {

      myMovie.jump(stressMovieVal[currentZone-1][intensity]);// (0, 1, 2, 3, 4) need to jump to 3 and 4
      return;
    }
  }

  void keepVideoLoopingInState() {

    if (myMovie.time() > stressMovieVal[currentZone-1][intensity+1]) {
      println("intensity "+ intensity + "val " +stressMovieVal[currentZone-1][intensity+1]);
      myMovie.jump (stressMovieVal[currentZone-1][intensity]);
    }
  }
}