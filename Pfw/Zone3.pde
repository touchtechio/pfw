class Zone3 {

  int xstart;
  int ystart;
  int xend;
  int yend;
  int centerPtX;
  int centerPtY;
  int pixelW;
  int greenPixel;

  void start() {

    return;
  }

  void draw() {
    //// for fixed starting point (center), the square scales up and down

    greenPixel = (int) map(smoothStressVal, 0, 100, 0, 350);
    pixelW = updateScatterScaleUpAndDown() + greenPixel;

    centerPtX = 1280/2;
    centerPtY = 780/2;

    xstart = constrain(centerPtX - pixelW/2, 0, myMovie.width); 
    ystart = constrain(centerPtY - pixelW/2, 0, myMovie.height);
    xend = constrain(centerPtX + pixelW/2, 0, myMovie.width);
    yend = constrain(centerPtY + pixelW/2, 0, myMovie.height);

    //// Either a using a pixel effect or a flat square
    drawSquare();

    displayStressData();

    return;
  }
  // replace framCount with bioSensing data;
  int updateScatterScaleUpAndDown () {
    //int scale = ((int)millis() % 21);
    int scale = (frameCount % 80);

    if (scale < 40) {
      return (40 - scale);
    }
    return (scale - 39);
  }
  // replace framCount with bioSensing data;

  void drawSquare() {
    for (int i = xstart; i < xend; i +=videoScale) {
      // Begin loop for rows
      for (int j = ystart; j < yend; j +=videoScale) {

        // Looking up the appropriate color in the pixel array
        int loc = i + j * myMovie.width;
        color c = myMovie.pixels[loc];
        //fill(c);
        offscreen.noStroke();
        offscreen.fill(125, 244, 38);
      }
    }
    offscreen.rectMode(CENTER);

    offscreen.rect(centerPtX + 220, centerPtY + 70, pixelW * 0.7, pixelW * 0.7); // right
    offscreen.rect(centerPtX - 230, centerPtY + 60, pixelW, pixelW); // left
    offscreen.rect(centerPtX + 40, centerPtY - 230, pixelW * 0.5, pixelW * 0.5); // top
  }
}