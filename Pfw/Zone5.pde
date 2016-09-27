
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
    checkForCalm();
    keepVideoLoopingInState();

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

      myMovie.jump(stressMovieVal[currentZone-1][intensity]);
      println("jumping up");
      lastIntensity=intensity; // keeps track of intensity state
      //gettingStressed = true;
      //turningState = false;
      //stressCount = 0;
      return;
    } else if (stressIntensityVal() < lastStressIntensityVal) {
      if (abs(stressIntensityVal() - lastStressIntensityVal) == 1) {
        myMovie.jump(stressMovieVal[currentZone-1][lastIntensity + 1]);// (0, 1, 2, 3) need to jump to 3 and 4
        println("jumping down");
        lastIntensity=lastIntensity + 1;
      }
    } else if (turningState) {
      myMovie.jump(stressMovieVal[currentZone-1][intensity]);
      lastIntensity=intensity;
      println("state turned");
      turningState = false;
    }
    //stressCount += 1;
    //gettingStressed = false; 

    return;
  }


  // resets to the rope pulling state -> if gone from med to low or from high to low
  void checkForCalm() { 
    if  (-(stressIntensityVal() - lastStressIntensityVal) == 2) {
      turningState = true;
      println("calmed");
      lastIntensity = lastIntensity + 1;
      return;
    }
  }

  void keepVideoLoopingInState() {
    // if(gettingStressed) {
    if (lastIntensity < 4) {
      if (myMovie.time() > stressMovieVal[currentZone-1][lastIntensity+1]) {
        myMovie.jump (stressMovieVal[currentZone-1][lastIntensity]);
        println("looping");
        println("lastStressVal "+lastStressIntensityVal+" lastIntensity "+lastIntensity);
        println("turningState " + turningState);
        return;
      }
    }
  }
}