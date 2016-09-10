/*
this sketch runs a movie that correlates to levels of stress
 Use OSC buttons or keypress 1,2,3,4 to jump to different states
 */

/// OSC
import oscP5.*;
import netP5.*;
OscP5 oscP5;

import deadpixel.keystone.*;
Keystone ks;
CornerPinSurface surface;
PGraphics offscreen;
int cornerPinX = 1280;
int cornerPinY = 720;

import processing.video.*;
Movie myMovie;
Movie myMovie2;
String movieNames[] = {"", "", "", "danger3.mp4", "rope3.mp4"};
Movie Movies[] = {myMovie};
int moviePlaying = 0;
int movX = 1280;
int movY = 720;
float textXPer = 0.7;
float textYPer = 0.7;

float stressMovieVal[] = {2.1, 8.0, 13, 22.0}; // times in the movie to jump to
float stressLow, stressHigh, stressMed, stressCrazy;
float stressType[] = {stressLow, stressHigh, stressMed, stressCrazy};
String oscAddr[] = {"/Stress/s2/1/1", "/Stress/s2/2/1", "/Stress/s2/1/2", "/Stress/s2/2/2"};

int zone[] = {1, 2, 3, 4, 5};
String oscZoneAddr[] = {"/Zones/s2/1/1", "/Zones/s2/2/1", "/Zones/s2/1/2", "/Zones/s2/2/2"};

float speed = 1.0;



boolean DEBUG = true; // determines whether to data on screen

PFont font;

/// zone state
int lastZone;
int currentZone = 5;

void tearDown() {
  if (DEBUG) println("tearing down zone.");
  myMovie.stop();
  return;
}
void setupZone1() {
  if (DEBUG) println("build zone 1");
  currentZone = 1;
  return;
}
void setupZone2() {
  if (DEBUG) println("build zone 2");
  currentZone = 2;
  myMovie = new Movie(this, "dancing2.mp4");
  myMovie2 = new Movie(this, "dancing3.mp4");
  
  myMovie.loop();
  myMovie2.loop();

  // changes speed of pixels appearing
  frameRate(10);
  return;
}
void setupZone3() {
  if (DEBUG) println("build zone 3");
  myMovie = new Movie(this, "rose_viz3.mp4");
  myMovie.loop();
  currentZone = 3;
  return;
}

int videoScale = 13;
int xstart;
int ystart;
int xend;
int yend;
int centerPtX;
int centerPtY;
int pixelW;
void setupZone4() {
  if (DEBUG) println("build zone 4");
  currentZone = 4;
  
  myMovie = new Movie(this, movieNames[currentZone-1]);
  myMovie.loop();
  return;
}
void setupZone5() {
  if (DEBUG) println("build zone 5");
  currentZone = 5;

  myMovie = new Movie(this, movieNames[currentZone-1]);
  myMovie.loop();
  return;
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


void  drawCurrentZone() {
  drawZone(currentZone);
  return;
}


void drawZone(int zone) {
  switch (zone) {
  case 1:
    drawZone1();
    return;
  case 2:
    drawZone2();
    return;
  case 3:
    drawZone3();
    return;
  case 4:
    drawZone4();
    return;
  case 5:
    drawZone5();
    return;
  }

  println("ERR: setup a non-existant Zone: " + zone);
}



void setup() {
  // Keystone will only work with P3D or OPENGL renderers, 
  // since it relies on texture mapping to deform
  size(1280, 720, P3D);

  font = createFont("HelveticaNeue", 15);

  ks = new Keystone(this);
  surface = ks.createCornerPinSurface(cornerPinX, cornerPinY, 20);

  // We need an offscreen buffer to draw the surface we
  // want projected
  // note that we're matching the resolution of the
  // CornerPinSurface.
  // (The offscreen buffer can be P2D or P3D)
  offscreen = createGraphics(cornerPinX, cornerPinY, P3D);

  ks.load();

  // start oscP5, listening for incoming messages at port 12000
  oscP5 = new OscP5(this, 12000);

  setupCurrentZone();
  return;
}

void movieEvent(Movie m) {
  m.read();
}

void draw() {
  background(0);

  // Draw the scene, offscreen
  offscreen.beginDraw();
  offscreen.background(0);

  /// play movie file
  offscreen.image(myMovie, 0, 0, 1280, 720);

  println("framRate " + frameRate);


  // do stuff specific for each zone here
  drawCurrentZone();


  offscreen.translate(cornerPinX/2, cornerPinY/2);
  offscreen.endDraw();

  // render the scene, transformed using the corner pin surface
  surface.render(offscreen);
  return;
}

void drawZone5() {


  offscreen.stroke(255);

  if (true) { 
    println("framRate " + frameRate);
    offscreen.textSize(15);
    offscreen.text("time " + myMovie.time(), .7 * movX, 0.1 * movY);
    displayStressData();
  }
  return;
}


void drawZone4() {
   offscreen.stroke(255);

  if (true) { 
    println("framRate " + frameRate);
    offscreen.textSize(15);
    offscreen.text("time " + myMovie.time(), .7 * movX, 0.1 * movY);
    displayStressData();
  }
}

void drawZone3() {


  //// for fixed starting point (center), the square scales up and down
  pixelW = updateScatterScaleUpAndDown() * videoScale;

  centerPtX = 1280/2;
  centerPtY = 780/2;

  xstart = constrain(centerPtX - pixelW/2, 0, myMovie.width); 
  ystart = constrain(centerPtY - pixelW/2, 0, myMovie.height);
  xend = constrain(centerPtX + pixelW/2, 0, myMovie.width);
  yend = constrain(centerPtY + pixelW/2, 0, myMovie.height);


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

// end Zone 3


void drawZone2() {
    offscreen.background(10, 0, 200);
  //offscreen.imageMode(CENTER);
  //offscreen.image(hotel,0,0, 1280, 780);
  //pixelMan.loadPixels();
  
  offscreen.pushMatrix();
  offscreen.translate(100, 0);
  drawGridBrightness();
  offscreen.popMatrix();
  offscreen.pushMatrix();
  offscreen.translate(200, 0);
  drawGridBrightness2();
  offscreen.popMatrix();
  
  //movieScrubber();
  //blackPixels.display(updateScatterScaleUpAndDown());
  //purplePixels.display(updateScatterScaleUpAndDown());

  myMovie.loadPixels();
  myMovie2.loadPixels();

  //scrubIndicator();
  //drawMoviePixels();
  


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

void drawZone1() {
}


void oscEvent(OscMessage theOscMessage) {
  print(" typetag:" + theOscMessage.typetag());
  print(" addrpattern: " +theOscMessage.addrPattern());
  println(theOscMessage.get(0).floatValue());

  for (int i = 0; i < oscAddr.length; i++) {
    if (theOscMessage.checkAddrPattern(oscAddr[i])==true) {
      stressType[i] = theOscMessage.get(0).floatValue();
      if (stressType[i] == 1.0) {
        myMovie.jump(stressMovieVal[i]);
        return;
      } else {
        // nothing
      }
    }
  }

  for (int i = 0; i < oscZoneAddr.length; i++) {
    if (theOscMessage.checkAddrPattern(oscZoneAddr[i])==true) {
      float value = theOscMessage.get(0).floatValue();
      if (value == 1.0) {
        currentZone = zone[i];
        setupZone(zone[i]);
        return;
      } else {
        // nothing
      }
    }
  }
}

void keyPressed() {
  switch(key) {
    
  /// keystoning keys
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

  /// stress level keys
  case 'q':
    myMovie.jump(stressMovieVal[0]);
    //return;
    break;
  case 'w':
    myMovie.jump(stressMovieVal[1]);
    return;
  case 'e':
    myMovie.jump(stressMovieVal[1]);
    //float stress3 = 21.0;
    //myMovie.jump(stress3);
    //stress3 -= 0.1;
    break;
  case 'r':
    myMovie.jump(stressMovieVal[3]);
    break;

  /// Zone switching
  case '1':
    tearDown();
    setupZone1();
    break;
  case '2':
    tearDown();
    setupZone2();
    break;
  case '3':
    tearDown();
    setupZone3();
    break;
  case '4':
    tearDown();
    setupZone4();
    break;
  case '5':
    tearDown();
    setupZone5();
    break;
  }
}

void mousePressed() {
  float mousePosRatio = mouseX/ (float)width;
  myMovie.jump(mousePosRatio* myMovie.duration());
  println((float)mousePosRatio * myMovie.duration());
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

void movieScrubber() {
  float mousePosRatio = mouseX/ (float)width;
  myMovie.jump(mousePosRatio* myMovie.duration());
  return;
}

void drawGridBrightness() {
  // Begin loop for columns
  for (int i = 0; i < myMovie.width; i +=videoScale) {
    // Begin loop for rows
    for (int j = 0; j < myMovie.height; j +=videoScale) {

      // Reversing x to mirror the image
      // In order to mirror the image, the column is reversed with the following formula:
      // mirrored column = width - column - 1
      //int loc = (myMovie.width - i - 1) + j*myMovie.width;
      // int loc = i + j * myMovie.width;
      int loc = i + j * myMovie.width;

      // Each rect is colored white with a size determined by brightness
      color c = myMovie.pixels[loc];

      // A rectangle size is calculated as a function of the pixel's brightness. 
      // A bright pixel is a large rectangle, and a dark pixel is a small one.
      float sz = (brightness(c)/255)*videoScale; 

      //offscreen.rectMode(CENTER);

      // draw growing purple pixel
      // chromakey
      //if (sz>2) {
      if(brightness(c) <50) {
       // offscreen.rect(i - pixelMan.width/2, j - pixelMan.height/2, videoScale, videoScale);
        if (0==(int) random(2) % 2 ) {
          // defines percentage of image to be colored
          //if (0==(int) random(updateScaleUpAndDown () ) % (updateScaleUpAndDown () + 1) ) {
          offscreen.fill(250, 98, 237);
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

void drawGridBrightness2() {
  // Begin loop for columns
  for (int i = 0; i < myMovie2.width; i +=videoScale) {
    // Begin loop for rows
    for (int j = 0; j < myMovie2.height; j +=videoScale) {

      // Reversing x to mirror the image
      // In order to mirror the image, the column is reversed with the following formula:
      // mirrored column = width - column - 1
      //int loc = (myMovie.width - i - 1) + j*myMovie.width;
      // int loc = i + j * myMovie.width;
      int loc = i + j * myMovie2.width;

      // Each rect is colored white with a size determined by brightness
      color c = myMovie2.pixels[loc];

      // A rectangle size is calculated as a function of the pixel's brightness. 
      // A bright pixel is a large rectangle, and a dark pixel is a small one.
      float sz = (brightness(c)/255)*videoScale; 

      //offscreen.rectMode(CENTER);

      // draw growing purple pixel
      // chromakey
      //if (sz>2) {
      if(brightness(c) <50) {
       // offscreen.rect(i - pixelMan.width/2, j - pixelMan.height/2, videoScale, videoScale);
        if (0==(int) random(2) % 2 ) {
          // defines percentage of image to be colored
          //if (0==(int) random(updateScaleUpAndDown () ) % (updateScaleUpAndDown () + 1) ) {
          offscreen.fill(250, 98, 237);
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