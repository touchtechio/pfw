

class Zone {



  void start() {
  if (DEBUG) println("build zone 4");

  return;

  }

  void draw() {

  offscreen.stroke(255);
  float theta = 0;
  intensity = stressIntensityVal();
  if (stressVal != lastStressVal) {
    myMovie.jump(stressMovieVal[currentZone-1][intensity]);
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


}
