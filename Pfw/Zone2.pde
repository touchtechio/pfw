class Zone2 {

  void start() {

    return;
  }

  void draw() {

    offscreen.background(25);

    // handle all on screen dancers with this code
    //
    dancers = onScreenDancerCount();

    // handle new dancers coming screen
    //
    for (int i = 0; i <= dancers; i++) {

      if (lastDancerCount < i) {
        movies[i].jump(0);
        movies[i].loop();
      }
    }

    // handle old dancers leaving screen
    //
    for (int i = 0; i <= lastDancerCount; i++) {
      if (dancers < i) {
        movies[i].jump(37);
        movies[i].noLoop();
      }
    }


    for (int i = 0; i < movies.length; i++) {
      offscreen.pushMatrix();
      //offscreen.translate(250 - i * 150, 0);
      if (movies[i].playbin.isPlaying()) {
        drawGridBrightness(i);
      }
      offscreen.popMatrix();
    }

    lastDancerCount = dancers;
    // println("dancers     "+dancers);
    // println("lastdancercount "+lastDancerCount);

    updatePixels();

    if (DEBUG) {
      //println("framRate " + frameRate);
      offscreen.fill(255);
      offscreen.textSize(15);
      offscreen.text("frameRate " + (int)frameRate, .7 * movX, 0.1 * movY);
      displayStressData();
      //println("time "+myMovie.time()); // if want to see timestamp of while movie plays
    }
  }

  int onScreenDancerCount() {
    // maps number of dancers from 1-5 based on stress values
    return (int) map(stressVal, 0, 100, 0, 7);
  }

  /// used in Zone2
  void drawGridBrightness(int state) {
    movies[state].loadPixels();
    // Begin loop for columns
    for (int i = 0; i < movX; i +=videoScale) {
      // Begin loop for rows
      for (int j = 0; j < movY; j +=videoScale) {

        int loc = i + j * movies[state].width;

        // Each rect is colored white with a size determined by brightness
        color c = movies[state].pixels[loc];

        // A rectangle size is calculated as a function of the pixel's brightness. 
        // A bright pixel is a large rectangle, and a dark pixel is a small one.
        float sz = (brightness(c)/255)*videoScale; 

        // chromakey
        if (brightness(c) <50) {
          // offscreen.rect(i - pixelMan.width/2, j - pixelMan.height/2, videoScale, videoScale);
          if (0==(int) random(2) % 2 ) {
            // defines percentage of image to be colored
            //if (0==(int) random(updateScaleUpAndDown () ) % (updateScaleUpAndDown () + 1) ) {
            offscreen.fill(250, 98, 237);
            //offscreen.fill(250, 98 + state * 30, 237/(state+1));
            offscreen.rect(i + videoScale/2, j + videoScale/2, videoScale, videoScale);
            //offscreen.rect(i - pixelMan.width/2, j - pixelMan.height/2, videoScale, videoScale);
            //} else if (1==(int) random(updateScaleUpAndDown ()) % updateScaleUpAndDown ()  ) {
          } else if (1==(int) random(2) % 2 ) {
            offscreen.fill(0);
            offscreen.rect(i + videoScale/2, j + videoScale/2, videoScale, videoScale);
            //offscreen.rect(i - pixelMan.width/2, j - pixelMan.height/2, videoScale, videoScale);
          } else {
            //offscreen.fill(0);
            //offscreen.rect(i + videoScale/2, j + videoScale/2, videoScale, videoScale);
            // clear
            // this can be blank
            offscreen.fill(0);
            offscreen.rect(i + videoScale/2, j + videoScale/2, videoScale, videoScale);
            // offscreen.rect(i + videoScale/2, j + videoScale/2, 0, 0);
            //offscreen.rect(i - pixelMan.width/2, j - pixelMan.height/2, 0, 0);
          }
          offscreen.noStroke();
        }
      }
    }
  }
}