/*
author: @adellelin
 
 this sketch runs a movie that correlates to levels of stress
 Use OSC buttons or keypress 1,2,3,4 to jump to different states
 */
import oscP5.*;
import netP5.*;
import deadpixel.keystone.*;
import processing.video.*;

// osc 
OscP5 oscP5;

// keystoning
Keystone ks;
CornerPinSurface surface;
PGraphics offscreen;
int cornerPinX = 1280;
int cornerPinY = 720;
int intensity;

// video 
Movie myMovie, myMovie2, myMovie3;
//String movieNames[] = {"", "", "", "danger3.mp4", "rope3.mp4"};
String movieNames[] = {"dance1.mp4", "dance2.mp4", "dance3.mp4"};
Movie movies[] = {myMovie, myMovie2, myMovie3};
int moviePlaying = 0;

// define zones
Zone1 zone1 = new Zone1();
Zone2 zone2 = new Zone2();
Zone3 zone3 = new Zone3();
Zone4 zone4 = new Zone4();
Zone5 zone5 = new Zone5();

int movX = 1280;
int movY = 720;
float textXPer = 0.7;
float textYPer = 0.7;
int videoScale = 0;
//float speed;
float lastStressVal;
float stressVal;

//glasses data
int trueHR;
int trueStressVal;
boolean hasGlasses = false;
boolean hasCalm = false;
boolean noData = true;
long beginStressManagement = 0L;

// zone movie jump points
float stressMovieVal[][] =
  { {0.0, 5.0, 10.0, 22.0}, 
  {0, 0, 0, 0}, 
  {0, 0, 0, 0}, 
  {0.5, 3.0, 8.0, 0.5}, 
  {1.0, 10.0, 16, 52.0}}; // times in the movie to jump to
float stressLow, stressHigh, stressMed, stressCrazy;
float stressType[] = {stressLow, stressHigh, stressMed, stressCrazy};
String oscAddr[] = {"/Stress/s2/1/1", "/Stress/s2/2/1", "/Stress/s2/1/2", "/Stress/s2/2/2"};

String oscZoneAddr[] = {"/Zone/switch/1/1", "/Zone/switch/2/1", "/Zone/switch/3/1", "/Zone/switch/4/1", "/Zone/switch/5/1"};
int zone[] = {1, 2, 3, 4, 5};

boolean DEBUG = true; // determines whether to data on screen

PFont font;

/// zone state
//
String thisHostsZone=System.getenv("ZONE");
int lastZone;
int currentZone = 1;

void tearDown() {
  if (DEBUG) println("tearing down zone.");

  myMovie.stop();

  for (int i = 1; i< movies.length; i++) {
    if (movies[i] != null) {
      movies[i].stop();
      println("tear "+ i);
    }
  }

  lastStressVal = 0;

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
  stressVal = 10;
  lastDancerCount = -1;

  // changes speed of pixels appearing
  videoScale = 4;
  zone2.start();
  if (DEBUG) println("build zone 2");
  for (int i = 0; i < movies.length; i ++) {
    movies[i] = new Movie(this, movieNames[i]);
    println("movies "+ movieNames[i]);
  }
  return;
}

void setupZone3() {
  if (DEBUG) println("build zone 3");
  myMovie = new Movie(this, "rose_3a.mp4");
  myMovie.loop();
  currentZone = 3;
  videoScale = 13;
  return;
}

void setupZone4() {
  if (DEBUG) println("build zone 4");
  currentZone = 4;

  myMovie = new Movie(this, "danger4.mp4");
  myMovie.loop();

  zone4.start();
  return;
}

void setupZone5() {
  if (DEBUG) println("build zone 5");
  currentZone = 5;

  myMovie = new Movie(this, "ropeLoop.mp4");
  myMovie.loop();

  zone5.start();
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


  // start oscP5 first, listening for incoming messages at port 12000
  oscP5 = new OscP5(this, 12000);


  // Keystone will only work with P3D or OPENGL renderers,
  // since it relies on texture mapping to deform
  size(1280, 720, P3D);


  font = createFont("HelveticaNeue", 15);

  ks = new Keystone(this);
  surface = ks.createCornerPinSurface(cornerPinX, cornerPinY, 20);
  offscreen = createGraphics(cornerPinX, cornerPinY, P3D);

  ks.load();

  // get start zone from local env
  if (null != thisHostsZone) {
    currentZone = Integer.parseInt(thisHostsZone);
  }

  //frameRate(24);

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
  if (currentZone!= 1)
    if (currentZone!= 2) {
      offscreen.image(myMovie, 0, 0, 1280, 720);
    }

  //println("framRate " + frameRate);

  // do stuff specific for each zone here
  drawCurrentZone();

  if (hasGlasses) { //checking to see if glasses has beeen put on
    gettingCalm(beginStressManagement);
  }

  offscreen.translate(cornerPinX/2, cornerPinY/2);
  offscreen.endDraw();

  // render the scene, transformed using the corner pin surface
  surface.render(offscreen);
  return;
}



void drawZone5() {
  zone5.draw();
}

void drawZone4() {
  zone4.draw();
}

void drawZone3() {
  zone3.draw();
}

// start Zone 2

void drawZone2() {
  zone2.draw();
}

void drawZone1() {
  zone1.draw();
}


void oscEvent(OscMessage theOscMessage) {
  print(" typetag:" + theOscMessage.typetag());
  println(" addrpattern: " +theOscMessage.addrPattern());

  if (theOscMessage.checkAddrPattern("/data")) {
    trueHR = theOscMessage.get(0).intValue();
    trueStressVal = theOscMessage.get(1).intValue();

    println ("HR " + trueHR + ", SR" + trueStressVal);

    if (noData && trueHR > 0) { //trueHR should be > 0 when glasses are put on
      manageGlassesStress();
    }

    if (hasCalm && trueHR < 10) { //trueHR < 10 when glasses taken off
      hasCalm = false;
      noData = true;
    }

    stressVal = trueStressVal;
  }

  for (int i = 0; i < oscAddr.length; i++) {

    // if (theOscMessage.checkAddrPattern(oscAddr[i])==true) {
    if (theOscMessage.checkAddrPattern( "/Stress/s1")==true) {
      stressVal = (int)theOscMessage.get(0).floatValue();
      //stressIntensityVal();
      println(stressVal);
      return;
 
    }
  }


  // check message for zone switch address
  for (int j = 0; j < oscZoneAddr.length; j++) {

    if (theOscMessage.checkAddrPattern(oscZoneAddr[j])) {
      float value = theOscMessage.get(0).floatValue();

      if (value == 1.0) {
        println("osc switch zone"+zone[j]);
        tearDown();
        println("osc switch zone"+zone[j]);
        setupZone(zone[j]);
        return;
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

    ///Global stress level keys
  case 'q':
    stressVal = 8;
    /*
    if (currentZone == 1) {
     myMovie.jump(stressMovieVal[currentZone - 1][3]);
     }
     */
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
    /*
  case 'y':
     stressVal = 80;
     break;
     case 'u':
     stressVal = 90;
     break;
     */
  case 'p':
    manageGlassesStress();
    println("hasGlasses "+hasGlasses+", NoData " +noData+ ", hasCalm "+hasCalm);
    break;
  case 'o': //resets to calm
    hasCalm = false;
    noData = true;
    println("hasGlasses "+hasGlasses+", NoData " +noData+ ", hasCalm "+hasCalm);
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
  float mousePosRatio = mouseX/ (float)width;
  myMovie.jump(mousePosRatio* myMovie.duration());
  return;
}

void manageGlassesStress() {
  hasGlasses = true;
  noData = false;
  stressVal = 90; // eventually to be replaced by real data
  beginStressManagement = millis();
  println("timer " + beginStressManagement);
  return;
}

void gettingCalm(float startTime) {
  if (millis() > startTime + 10000) {
    hasCalm = true;
    hasGlasses = false;
    println("calming down");
    return;
  }
}
