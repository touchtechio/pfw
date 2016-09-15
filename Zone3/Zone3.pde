/// Keystoning

import deadpixel.keystone.*;

Keystone ks;
CornerPinSurface surface;

PGraphics offscreen;
int cornerPinX = 1280;
int cornerPinY = 720;

/// OSC
import oscP5.*;
import netP5.*;
OscP5 oscP5;
NetAddress myRemoteLocation;

import processing.video.*;

Movie myMovie;
int videoScale = 1;
int movX = 1280;
int movY = 720;

int xstart;
int ystart;
int xend;
int yend;
int centerPtX;
int centerPtY;
int pixelW;
float textXPer = 0.7;
float textYPer = 0.7;

boolean DEBUG = true;  // determines whether to data on screen

PFont font;

void setup() {
  size(1280, 720, P3D);

  font = createFont("HelveticaNeueu", 15);

  /// keystone 
  ks = new Keystone(this);
  surface = ks.createCornerPinSurface(cornerPinX, cornerPinY, 20);
  // (The offscreen buffer can be P2D or P3D)
  offscreen = createGraphics(cornerPinX, cornerPinY, P3D);
  ks.load();

  // start oscP5, listening for incoming messages at port 12000
  oscP5 = new OscP5(this, 12000);
  // netAddress("device IP", outgoing port)
  myRemoteLocation = new NetAddress("192.168.1.9", 9000);

  myMovie = new Movie(this, "rose_viz3.mp4");
  //myMovie2 = new Movie
  myMovie.loop();
  videoScale = 13;
  //frameRate(10);
  //myMovie.speed(2.0);
}


void movieEvent(Movie m) {
  m.read();
}

void draw() {

  /// Change SquareSize
  
  //videoScale = updateFlatScaleUpAndDown();
  background(0);

  // Convert the mouse coordinate into surface coordinates
  // this will allow you to use mouse events inside the 
  // surface from your screen. 
  //PVector surfaceMouse = surface.getTransformedMouse();

  // Draw the scene, offscreen
  offscreen.beginDraw();
  background(0);
  //// if just want movie to play
  offscreen.image(myMovie, 0, 0, 1280, 780);

  println("framRate " + frameRate);

  // offscreen.strokeWeight(5);
  //offscreen.ellipse(surfaceMouse.x, surfaceMouse.y, 75, 75);

  //// for fixed starting point (center), the square scales up and down
  pixelW = updateScatterScaleUpAndDown () * videoScale;

  centerPtX = 1280/2;
  centerPtY = 780/2;

  //// for starting point influenced by mouse, can input Biosensing data here
  //pixelW = videoScale * 10;
  //centerPtX = mouseX;
  //centerPtY = mouseY;

  xstart = constrain(centerPtX - pixelW/2, 0, myMovie.width); 
  ystart = constrain(centerPtY - pixelW/2, 0, myMovie.height);
  xend = constrain(centerPtX + pixelW/2, 0, myMovie.width);
  yend = constrain(centerPtY + pixelW/2, 0, myMovie.height);
  //println(xstart+ "," + ystart+ "," + xend+ "," + yend);

  //movieScrubber();

  // myMovie.loadPixels();


  //// Either a using a pixel effect or a flat square

  drawSquare();
  if (DEBUG) {
    println("framRate " + frameRate);
    offscreen.fill(255);
    offscreen.textSize(15);
    offscreen.text("frameRate " + (int)frameRate, .7 * movX, 0.1 * movY);
    displayStressData();
    //println("time "+myMovie.time()); // if want to see timestamp of while movie plays
  }
  offscreen.endDraw();
  surface.render(offscreen);
}

void drawMoviePixels() {
  // Begin loop for columns
  for (int i = xstart; i < xend; i +=videoScale) {
    // Begin loop for rows
    for (int j = ystart; j < yend; j +=videoScale) {

      // Looking up the appropriate color in the pixel array
      int loc = i + j * myMovie.width;
      color c = myMovie.pixels[loc];
      fill(c);
      //stroke(0);
      rect(i, j, videoScale, videoScale);
    }
  }
}

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

  offscreen.rect(centerPtX + 170, centerPtY + 90, pixelW, pixelW ); // right
  offscreen.rect(centerPtX - 280, centerPtY + 80, pixelW, pixelW); // left
  offscreen.rect(centerPtX + 40, centerPtY - 210, pixelW * 0.8, pixelW * 0.8); // top
}


void movieScrubber() {
  float mousePosRatio = mouseX/ (float)width;
  myMovie.jump(mousePosRatio* myMovie.duration());
  println(mousePosRatio* myMovie.duration());
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

void keyPressed() {
  switch(key) {
  case 'c':
    // enter/leave calibration mode, where surfaces can be warped 
    // and moved
    ks.toggleCalibration();
    break;

  case 'l':
    // loads the saved layout
    ks.load();
    break;

  case 's':
    // saves the layout
    ks.save();
    break;
  }
}

void displayStressData() {
  for (int i = 0; i < 30; i++) {
    offscreen.ellipse(textXPer * movX + i * 10, textYPer * movY, 3, 3);
  }
  offscreen.textSize(24);
  offscreen.fill(255);
  // data input shown on screen
  offscreen.text("brainwave frequency", textXPer * movX, (textYPer + 0.09) * movY);
  offscreen.text("respiratory rate", textXPer * movX, (textYPer + 0.14) * movY);
  offscreen.text("heart rate", textXPer * movX, (textYPer + 0.19) * movY);
  offscreen.textSize(20);
  offscreen.text(frameCount % 35, (textXPer + 0.2) * movX, (textYPer + 0.09) * movY);
  offscreen.text(frameCount % 100, (textXPer + 0.2) * movX, (textYPer + 0.14) * movY);
  offscreen.text(frameCount % 150, (textXPer + 0.2) * movX, (textYPer + 0.19) * movY);
}