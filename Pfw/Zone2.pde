class Zone2 {
  boolean enterDancingState[] = {false, false, false};
  boolean dancingLoop[] = {false, false, false};
  float keepDancingJumpPoints[] = {4.0, 5.0, 2.0}; 
  float jumpPoints[] = {37.0, 36.0, 18.0};

  long dancingTimer[] = {0, 0, 0};

  void start() {

    return;
  }

  void draw() {

    offscreen.background(0);

    // handle all on screen   with this code
    //
    dancers = onScreenDancerCount();

    // handle new dancers coming screen
    //
    for (int i = 0; i <= dancers; i++) {

      if (lastDancerCount < i) {
        movies[i].jump(0);
        movies[i].loop();
        enterDancingState[i] = true;
        println(i + " enter state " + enterDancingState[i]);
      }
    }

   // loop first movie so dancer never leaves screen
    if (movies[0].time() > jumpPoints[0]) {
      println("reached end");
      movies[0].jump(keepDancingJumpPoints[0]);
    }

    // handle old dancers leaving screen
    //
    for (int i = 0; i <= lastDancerCount; i++) {
      if (dancers < i) {
        movies[i].jump(jumpPoints[i]);
        movies[i].noLoop();
        enterDancingState[i] = false;
      }
    }

    for (int i = 0; i < movies.length; i++) {
      offscreen.pushMatrix();
      //offscreen.translate(250 - i * 150, 0);
      if (movies[i].playbin.isPlaying()) {
        offscreen.scale(2);
        movies[0].speed(0.7);
        drawGridBrightness(i);
      }
      offscreen.popMatrix();
    }

    startDancingLoop(dancers);

    lastDancerCount = dancers;
    //println("dancers     "+dancers);
    // println("lastdancercount "+lastDancerCount);
    updatePixels();
    displayStressData();
  }

  int onScreenDancerCount() {
    // maps number of dancers from 1-5 based on stress values
    int dancers = stressIntensityVal();
    // println("dancers: " +dancers);
    return dancers;
  }

  void startDancingLoop(int dancers) {
    for (int i = 0; i <= dancers; i++) {
      if (enterDancingState[i]) {
        println(movies[1].time() + " end " +jumpPoints[1]);
        if (movies[i].time() > jumpPoints[i]) {
          println("reached end");
          movies[i].jump(keepDancingJumpPoints[i]);
          return;
        }
      }
    }
  }

  /// used in Zone2
  void drawGridBrightness(int state) {

    movies[state].loadPixels();
    // Begin loop for columns
    for (int i = 0; i < 640; i +=videoScale) {
      // Begin loop for rows
      for (int j = 0; j < 360; j +=videoScale) {

        int loc = i + j * movies[state].width;

        // Each rect is colored white with a size determined by brightness
        if (movies[state].pixels.length == 0) {
          println("000");
          break;
        }

        color c = movies[state].pixels[loc];

        // A rectangle size is calculated as a function of the pixel's brightness. 
        // A bright pixel is a large rectangle, and a dark pixel is a small one.
        //float sz = (brightness(c)/255)*videoScale; 

        // chromakey
        if (brightness(c) <50) {
          // offscreen.rect(i - pixelMan.width/2, j - pixelMan.height/2, videoScale, videoScale);
          if (0==(int) random(2) % 2 ) {
            // defines percentage of image to be colored
            //if (0==(int) random(updateScaleUpAndDown () ) % (updateScaleUpAndDown () + 1) ) {
            offscreen.fill(125, 244, 38);
            //offscreen.fill(250, 98 + state * 30, 237/(state+1));
            offscreen.rect(i + videoScale/2, j + videoScale/2, videoScale, videoScale);
            //offscreen.rect(i - pixelMan.width/2, j - pixelMan.height/2, videoScale, videoScale);
            //} else if (1==(int) random(updateScaleUpAndDown ()) % updateScaleUpAndDown ()  ) {
          } else if (1==(int) random(2) % 2 ) {
            offscreen.fill(0);
            offscreen.rect(i + videoScale/2, j + videoScale/2, videoScale, videoScale);
            //offscreen.rect(i - pixelMan.width/2, j - pixelMan.height/2, videoScale, videoScale);
          } else {
          }
          offscreen.noStroke();
        }
      }
    }
  }
}