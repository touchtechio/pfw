
class Zone5 {

  int intensity;
  int lastIntensity;
  int lastStressIntensityVal;
  boolean gettingStressed = false;
  int stressCount = 0;
  float startResetTimer;
  boolean gettingCalm;
  boolean turningState;


  void start() {
    //if (DEBUG) println("build zone 5");
    lastIntensity = -1;
    lastStressIntensityVal = -1;
    hasCalm = false;
    turningState = false;
    return;
  }

  void draw() {

    offscreen.stroke(255);
    // myMovie.speed(movieSpeed()); 

    intensity = stressIntensityVal(); // set this to correlate to zone jumps

    //println(myMovie.time());
    //println("value of stress change " + abs(stressIntensityVal() - lastStressIntensityVal));
    checkStressState();
  

    keepVideoLoopingInState();
    updateVideoState(); 

    lastStressIntensityVal = stressIntensityVal(); // used to determine states
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

  void checkStressState() {
    if (stressIntensityVal() > lastStressIntensityVal) {
      lastIntensity=intensity;
      println("jumping up");
      gettingStressed = true;

      return;
    } else if (stressIntensityVal() < lastStressIntensityVal) {

      if (stressIntensityVal() == 1) {
        lastIntensity=lastIntensity + 1;

        println("jumping down");
        gettingCalm = true;
      } 
      else if (stressIntensityVal() == 0) {
        lastIntensity = 0;
        turningState = true;
        println("state turned");
      }
      return;
    } 
    return;
  }

  void updateVideoState() {
    if (gettingStressed ) {
      myMovie.jump(stressMovieVal[currentZone-1][lastIntensity]);
      //println("last intensity" + lastIntensity);
      gettingStressed = false;
    } else if (turningState) {
      myMovie.jump(stressMovieVal[currentZone-1][lastIntensity]);
      turningState = false;
    } else if (gettingCalm) {
      myMovie.jump(stressMovieVal[currentZone-1][lastIntensity]);
      gettingCalm = false;
    }
  }
  void keepVideoLoopingInState() {
    // if(gettingStressed) {
    if (lastIntensity < 4 && !turningState) {
      if (myMovie.time() > stressMovieVal[currentZone-1][lastIntensity+1]) {
        myMovie.jump (stressMovieVal[currentZone-1][lastIntensity]);
        println("looping");
        //println("lastStressVal "+lastStressIntensityVal+" lastIntensity "+lastIntensity);
        //println("turningState " + turningState);
        return;
      }
    } else {
    }
  }
}