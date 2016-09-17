/*
this sketch runs a movie that correlates to levels of stress
 Use OSC buttons or keypress 1,2,3,4 to jump to different states
 */

/// OSC
import oscP5.*;
import netP5.*;
OscP5 oscP5;
NetAddress myRemoteLocation;

import deadpixel.keystone.*;
Keystone ks;
CornerPinSurface surface;
PGraphics offscreen;
int cornerPinX = 1280;
int cornerPinY = 720;
int intensity;

import processing.video.*;
Movie myMovie, myMovie2, myMovie3, myMovie4, myMovie5, myMovie6, myMovie7;
//String movieNames[] = {"", "", "", "danger3.mp4", "rope3.mp4"};
String movieNames[] = {"dance1.mp4", "dance2.mp4", "dance3.mp4", "dance4.mp4", "dance5.mp4", "dance6.mp4", "dance7.mp4"};
Movie movies[] = {myMovie, myMovie2, myMovie3, myMovie4, myMovie5, myMovie6, myMovie7};
int moviePlaying = 0;

Zone1 zone1 = new Zone1();

int movX = 1280;
int movY = 720;
float textXPer = 0.7;
float textYPer = 0.7;
int videoScale = 0;
float speed;
float lastStressVal;
float stressVal;

//glasses data
int trueHR = 0; 
int trueStressVal = 0;
boolean hasGlasses = false;
boolean hasCalm = false;
boolean noData = true;
long beginStressManagement = 0L;

float stressMovieVal[][] = 
  {{40.0, 5.0, 10.0, 22.0}, 
  {0, 0, 0, 0}, 
  {0, 0, 0, 0}, 
  {0.5, 8.0, 16.0, 26.0}, 
  {2.1, 8.0, 13, 22.0, 52.0}}; // times in the movie to jump to
float stressLow, stressHigh, stressMed, stressCrazy;
float stressType[] = {stressLow, stressHigh, stressMed, stressCrazy};
String oscAddr[] = {"/Stress/s2/1/1", "/Stress/s2/2/1", "/Stress/s2/1/2", "/Stress/s2/2/2"};

int zone[] = {1, 2, 3, 4, 5};
String oscZoneAddr[] = {"/Zone/switch/1/1", "/Zone/switch/2/1", "/Zone/switch/3/1", "/Zone/switch/4/1", "/Zone/switch/5/1"};

boolean DEBUG = true; // determines whether to data on screen

PFont font;

/// zone state
int lastZone;
int currentZone = 5;

void tearDown() {
  if (DEBUG) println("tearing down zone.");
  myMovie.stop();

  for (int i = 1; i< movies.length; i++) {
    if (movies[i] != null) {
      movies[i].stop();
      println("tear "+ i);
    }
  }
  

  return;
}



void setupZone1() {


  if (DEBUG) println("build zone 1");

  myMovie = new Movie(this, "rose5.mp4"); 
  myMovie.loop();

  zone1.start();

  currentZone = 1;
  return;
}

int lastDancerCount;
int dancers;

void setupZone2() {
  currentZone = 2;
  lastStressVal = 0;
  stressVal = 10;
  lastDancerCount = -1;
  //frameRate(10);
  // changes speed of pixels appearing
  videoScale = 12;
  if (DEBUG) println("build zone 2");
  for (int i = 0; i < movies.length; i ++) {
    movies[i] = new Movie(this, movieNames[i]);
    println("movies "+ movieNames[i]);
  }
  return;
}


int xstart;
int ystart;
int xend;
int yend;
int centerPtX;
int centerPtY;
int pixelW;
int greenPixel;

void setupZone3() {
  if (DEBUG) println("build zone 3");
  myMovie = new Movie(this, "rose_viz3.mp4");
  myMovie.loop();
  currentZone = 3;
  videoScale = 13;
  return;
}

void setupZone4() {
  if (DEBUG) println("build zone 4");
  currentZone = 4;

  myMovie = new Movie(this, "danger3.mp4");
  myMovie.loop();
  return;
}
void setupZone5() {
  if (DEBUG) println("build zone 5");
  currentZone = 5;

  lastStressVal = 0;
  //myMovie = new Movie(this, movieNames[currentZone-1]);
  myMovie = new Movie(this, "ropeLoop.mp4");
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
  frameRate(24);
  font = createFont("HelveticaNeue", 15);

  ks = new Keystone(this);
  surface = ks.createCornerPinSurface(cornerPinX, cornerPinY, 20);
  offscreen = createGraphics(cornerPinX, cornerPinY, P3D);

  ks.load();

  // start oscP5, listening for incoming messages at port 12000
  oscP5 = new OscP5(this, 12000);
  myRemoteLocation = new NetAddress("10.175.88.76", 9000);

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

  //println("framRate " + frameRate);

  // do stuff specific for each zone here
  drawCurrentZone();

  offscreen.translate(cornerPinX/2, cornerPinY/2);
  offscreen.endDraw();

  // render the scene, transformed using the corner pin surface
  surface.render(offscreen);
  return;
}

int stressIntensityVal() {
  // maps number of dancers from 1-5 based on stress values
  return (int) map(stressVal, 0, 100, 0, 4);
}

void drawZone5() {

  offscreen.image(myMovie, 0, 0, 1280, 720);


  offscreen.stroke(255);
  if (hasGlasses) {
    gettingCalm(beginStressManagement);
  }

  //float theta = 0;
  intensity = stressIntensityVal();
  if (stressVal > lastStressVal) {
    myMovie.jump(stressMovieVal[currentZone-1][intensity]);
  } else if (stressVal < lastStressVal || hasCalm) {
    myMovie.jump(stressMovieVal[currentZone-1][4]);
    hasCalm = false;
    // myMovie
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
  return;
}

float updateMovieScrub () {
  //frameRate(10);

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

void drawZone4() {

  offscreen.image(myMovie, 0, 0, 1280, 720);


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

void drawZone3() {

  offscreen.image(myMovie, 0, 0, 1280, 720);

  //// for fixed starting point (center), the square scales up and down
  greenPixel = (int) map(stressVal, 0, 100, 0, 350);
  pixelW = updateScatterScaleUpAndDown() + greenPixel;

  centerPtX = 1280/2;
  centerPtY = 780/2;

  xstart = constrain(centerPtX - pixelW/2, 0, myMovie.width); 
  ystart = constrain(centerPtY - pixelW/2, 0, myMovie.height);
  xend = constrain(centerPtX + pixelW/2, 0, myMovie.width);
  yend = constrain(centerPtY + pixelW/2, 0, myMovie.height);

  //// Either a using a pixel effect or a flat square

  drawSquare();
  if (DEBUG) {
    //println("framRate " + frameRate);
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

  offscreen.rect(centerPtX + 170, centerPtY + 90, pixelW * 0.7, pixelW * 0.7); // right
  offscreen.rect(centerPtX - 280, centerPtY + 60, pixelW, pixelW); // left
  offscreen.rect(centerPtX + 40, centerPtY - 230, pixelW * 0.5, pixelW * 0.5); // top
}

// end Zone 3

// start Zone 2

void drawZone2() {

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

void drawZone1() {
  zone1.draw();
}


void oscEvent(OscMessage theOscMessage) {
  print(" typetag:" + theOscMessage.typetag());
  print(" addrpattern: " +theOscMessage.addrPattern());

  if (theOscMessage.checkAddrPattern("/data")) {
    trueHR = theOscMessage.get(0).intValue();
    trueStressVal = theOscMessage.get(1).intValue();
    if (DEBUG) println ("HR " + trueHR + ", SR" + trueStressVal);

    if (noData && trueHR > 0) { // sets the point where data comes in and stress goes nuts
      manageGlassesStress();
    }
    if (hasCalm && trueHR <10) {
      hasCalm = false;
      noData = true;
    }
  }

  for (int i = 0; i < oscAddr.length; i++) {

    // if (theOscMessage.checkAddrPattern(oscAddr[i])==true) {
    if (theOscMessage.checkAddrPattern( "/Stress/s1")==true) {
      stressVal = (int)theOscMessage.get(0).floatValue();
      //stressIntensityVal();
      println(stressVal);
      return;
      /*
      stressType[i] = theOscMessage.get(0).floatValue();
       if (stressType[i] == 1.0) {
       
       myMovie.jump(stressMovieVal[currentZone - 1][i]);
       return;
       } else {
       // nothing
       }
       */
    }
  }

  for (int j = 0; j < oscZoneAddr.length; j++) {
    if (theOscMessage.checkAddrPattern(oscZoneAddr[j])==true) {
      float value = theOscMessage.get(0).floatValue();
      if (value == 1.0) {
      tearDown();
      println("zone"+zone[j]);
      // myMovie.stop();
      setupZone(zone[j]);
      //setupZone1();
      return;
      }
      // } else {
      // nothing
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

      /// Zone 4 and 5 stress level keys

    case 'v':
      myMovie.jump(stressMovieVal[currentZone - 1][0]);
      //return;
      break;
    case 'b':
      myMovie.jump(stressMovieVal[currentZone - 1][1]);
      return;
    case 'n':
      myMovie.jump(stressMovieVal[currentZone - 1][2]);
      //float stress3 = 21.0;
      //myMovie.jump(stress3);
      //stress3 -= 0.1;
      break;
    case 'm':
      myMovie.jump(stressMovieVal[currentZone - 1][3]);
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

      ///Zone2 stress level keys
    case 'q':
      stressVal = 0 ;
      if (currentZone == 1) {
        myMovie.jump(stressMovieVal[currentZone - 1][3]);
      }
      break;

    case 'w':
      stressVal = 20;
      break;

    case 'e':
      stressVal = 35;
      break;

    case 'r':
      stressVal = 45;
      break;

    case 't':
      stressVal = 65;
      break;

    case 'y':
      stressVal = 80;
      break;

    case 'u':
      stressVal = 90;
      break;

    case 'p':
      manageGlassesStress();

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
    offscreen.text("stress rate", textXPer * movX, (textYPer + 0.24) * movY);
    offscreen.textSize(20);
    offscreen.text(frameCount % 35, (textXPer + 0.2) * movX, (textYPer + 0.09) * movY);
    offscreen.text(frameCount % 100, (textXPer + 0.2) * movX, (textYPer + 0.14) * movY);
    offscreen.text(trueHR, (textXPer + 0.2) * movX, (textYPer + 0.19) * movY);
    offscreen.text(trueStressVal, (textXPer + 0.2) * movX, (textYPer + 0.24) * movY);

    /*
  offscreen.text(frameCount % 35, (textXPer + 0.2) * movX, (textYPer + 0.09) * movY);
     offscreen.text(frameCount % 100, (textXPer + 0.2) * movX, (textYPer + 0.14) * movY);
     offscreen.text(frameCount % 150, (textXPer + 0.2) * movX, (textYPer + 0.19) * movY);
     offscreen.text((int) stressVal + (frameCount % 7), (textXPer + 0.2) * movX, (textYPer + 0.24) * movY);
     */
  }

  void movieScrubber() {
    float mousePosRatio = mouseX / (float)width;
    myMovie.jump(mousePosRatio* myMovie.duration());
    return;
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
            //offscreen.fill(250, 98 + state * 30, 237/(state+1));
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

  void manageGlassesStress() {
    hasGlasses = true;
    noData = false;
    stressVal = 90; // eventually to be replaced by real data
    beginStressManagement = millis();
    println(beginStressManagement);
    return;
  }


  void gettingCalm(float startTime) {
    if (millis() > startTime + 10000) {
      hasCalm = true;
      hasGlasses = false;
      return;
    }
  }