import deadpixel.keystone.*;
Keystone ks;
CornerPinSurface surface;
PGraphics offscreen;
int cornerPinX = 1280;
int cornerPinY = 720;

import processing.video.*;

Movie myMovie, myMovie2, myMovie3, myMovie4, myMovie5;
String movieNames[] = {"dance5.mp4", "dance2.mp4", "dance3.mp4", "dance4.mp4", "dance1.mp4"};
Movie movies[] = {myMovie, myMovie2, myMovie3, myMovie4, myMovie5};
int moviePlaying = 0;

int videoScale = 8;
int cols, rows;

int movX;
int movY;

float textXPer = 0.7;
float textYPer = 0.7;

boolean DEBUG = false;  // determines whether to data on screen

PFont font;

float scaleNumber;

int currentZone = 2;
int lastDancerCount = -1;
float stressVal = 10;
int dancers;

void setup() {
  size(1280, 720, P3D);

  font = createFont("HelveticaNeueu", 15);

  ks = new Keystone(this);
  surface = ks.createCornerPinSurface(cornerPinX, cornerPinY, 20);
  offscreen = createGraphics(cornerPinX, cornerPinY, P3D);
  //ks.load();
  setupCurrentZone();
  //myMovie.speed(2.0); 
  movX = 1280;
  movY = 720;
}


void movieEvent(Movie m) {
  m.read();
}

void draw() {
  //// scale of pixels here. To replace with biosensing data

  // videoScale = updateFlatScaleUpAndDown();

  offscreen.beginDraw();
  drawZone2();
  offscreen.translate(cornerPinX/2, cornerPinY/2);
  offscreen.endDraw();
  surface.render(offscreen);
}

void drawGridBrightness(int state) {
  movies[state].loadPixels();
  // Begin loop for columns
  for (int i = 0; i < movX; i +=videoScale) {
    // Begin loop for rows
    for (int j = 0; j < movY; j +=videoScale) {

      // Reversing x to mirror the image
      // In order to mirror the image, the column is reversed with the following formula:
      // mirrored column = width - column - 1
      //int loc = (myMovie.width - i - 1) + j*myMovie.width;
      // int loc = i + j * myMovie.width;
      int loc = i + j * movies[state].width;

      // Each rect is colored white with a size determined by brightness
      color c = movies[state].pixels[loc];

      // A rectangle size is calculated as a function of the pixel's brightness. 
      // A bright pixel is a large rectangle, and a dark pixel is a small one.
      float sz = (brightness(c)/255)*videoScale; 

      //offscreen.rectMode(CENTER);

      // draw growing purple pixel
      // chromakey
      //if (sz>2) {
      if (brightness(c) <50) {
        // offscreen.rect(i - pixelMan.width/2, j - pixelMan.height/2, videoScale, videoScale);
        if (0==(int) random(2) % 2 ) {
          // defines percentage of image to be colored
          //if (0==(int) random(updateScaleUpAndDown () ) % (updateScaleUpAndDown () + 1) ) {
          offscreen.fill(250, 98 + state * 30, 237/(state+1));
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

void scrubIndicator() {
  float jumpPoint = myMovie.time()/myMovie.duration();
  fill(200, 0, 50);
  noStroke();
  ellipse(jumpPoint * width, movY + 40, 20, 20);
}


// replace framCount with bioSensing data;
int updateScaleUpAndDown () {
  //int scale = ((int)millis() % 21);
  int scale = (frameCount %10) ;
  println("scale "+scale);
  if (scale < 5) {
    return (5 - scale);
  }
  return (scale - 4);
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

  case 'q':
    stressVal = 10;
    break;

  case 'w':
    stressVal = 30;
    break;

  case 'e':
    stressVal = 50;
    break;

  case 'r':
    stressVal = 70;
    break;

  case 't':
    stressVal = 90;
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

void setupCurrentZone() {
  setupZone(currentZone);
  return;
}

void setupZone(int zone) {
  switch (zone) {
  case 1:
    setupZone1();
    return;
  case 2:
    setupZone2();
    return;
  case 3:
    setupZone3();
    return;
  case 4:
    setupZone4();
    return;
  case 5:
    setupZone5();
    return;
  }
  println("ERR: setup a non-existant Zone: " + zone);
}

void tearDown() {
  if (DEBUG) println("tearing down zone.");
  return;
}

void setupZone1() {
  if (DEBUG) println("build zone 1");
  return;
}
void setupZone2() {
  if (DEBUG) println("build zone 2");
  for (int i = 0; i < movies.length; i ++) {
    movies[i] = new Movie(this, movieNames[i]);
    //movies[i].loop();
  }

  // changes speed of pixels appearing
  frameRate(10);
  return;
}
void setupZone3() {
  if (DEBUG) println("build zone 3");
  return;
}
void setupZone4() {
  if (DEBUG) println("build zone 4");
  //myMovie = new Movie(this, movieNames[moviePlaying]);
  //myMovie.loop();
  return;
}
void setupZone5() {
  if (DEBUG) println("build zone 5");
  return;
}

void drawZone2() {

  offscreen.background(25);

  // handle all on screen dancers with this code
  //
  dancers = onScreenDancerCount();

  // handle new dancers
  //
  for (int i = 0; i <= dancers; i++) {

    if (lastDancerCount < i) {
      movies[i].jump(0);
      movies[i].loop();
      println("movieNumber " + i);
    }
  }

  // handle old dancers
  //
  for (int i = 0; i <= lastDancerCount; i++) {
    if (dancers < i) {
      movies[i].jump(35);
      movies[i].noLoop();
      println("movieNoLoop "+i);
      // movies[j].play();
      //drawGridBrightness(j);
      //lastDancerCount = dancers;
    }
  }


  for (int i = 0; i < 5; i++) {
    offscreen.pushMatrix();
    offscreen.translate(250 - i * 150, 0);
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
    println("framRate " + frameRate);
    offscreen.fill(255);
    offscreen.textSize(15);
    offscreen.text("frameRate " + (int)frameRate, .7 * movX, 0.1 * movY);
    displayStressData();
    //println("time "+myMovie.time()); // if want to see timestamp of while movie plays
  }
}

int onScreenDancerCount() {
  // maps number of dancers from 1-5 based on stress values
  return (int) map(stressVal, 0, 100, 0, 5);
}