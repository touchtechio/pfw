/*
author: @adellelin @mpinner
 
 this sketch runs a movie that correlates to levels of stress
 Use OSC buttons or keypress 1,2,3,4 to jump to different states
 */
import oscP5.*;
import netP5.*;
import deadpixel.keystone.*;
import processing.video.*;

// osc fra
OscP5 oscP5;

// keystoning
Keystone ks;
CornerPinSurface surface;
PGraphics offscreen;
int cornerPinX = 1280;
int cornerPinY = 720;

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
Blackout blackout = new Blackout();

int movX = 1280;
int movY = 720;

float textXPer = 0.025; // distance off the left side of screen
float textYPer = 0.09; // distance off top of screen
float numSpacing = 0.18;
int textDotNumber = 31;

int HUDtextSize = 30;
PFont HUDFont;
PFont HUDArrowFont;

int videoScale = 0;

float lastStressVal; // global for zone4 and zone5 stress caching
float smoothStressVal; // drives the content
float stressVal;  // set by incoming data
int smoothStressIntensity;

//glasses data
// todo: make neater
int trueHR = 72;
int trueBrainVal = 20;
int trueBreatheVal = 1507;

boolean hasGlasses = false;
boolean hasCalm = false;
boolean noData = true;
long beginStressManagement = 0L;

// zone movie jump points
float stressMovieVal[][] =
  {{4.0, 0.5}, 
  {0, 0, 0, 0}, 
  {0, 0, 0, 0}, 
  {0.2, 9.2, 19.2, 24.5}, 
  {1.0, 17.2, 26, 41.0, 66.0}}; // times in the movie to jump to, last jump 51.1
float stressLow, stressHigh, stressMed, stressCrazy;
float stressType[] = {stressLow, stressHigh, stressMed, stressCrazy};
String oscAddr[] = {"/Stress/s2/1/1", "/Stress/s2/2/1", "/Stress/s2/1/2", "/Stress/s2/2/2"};

String oscZoneAddr[] = {"/Zone/switch/1/1", "/Zone/switch/2/1", "/Zone/switch/3/1", "/Zone/switch/4/1", "/Zone/switch/5/1"};
int zone[] = {1, 2, 3, 4, 5};
int moments[][] = 
  {{100, 10}, //high stress, low stress
  {10, 100}, // low, hight
  {100, 10}, // high, low  
  {10, 100}, // low, high
  {10, 100}}; // low, high

long impactWaitDuration = 2000;

long lastImapactTime = 0;

/// these are for breathe
int shortBR1 = 800;
int shortBR2 = 1400;

int medBR1 = 1401;
int medBR2 = 2300;

int longBR1 = 2301;
int longBR2 = 8000;

int longRangeVal = (int)random(longBR1, longBR2);
int shortRangeVal = (int)random(shortBR1, shortBR2);

int OSCValues[][] = 
  {{shortRangeVal, longRangeVal}, 
  {longRangeVal, shortRangeVal}, 
  {shortRangeVal, longRangeVal}, 
  {longRangeVal, shortRangeVal}, 
  {longRangeVal, shortRangeVal}};

boolean arrayCleared = true;

boolean DEBUG = true; // determines whether to data on screen

/// zone state
//
String thisHostsZone=System.getenv("ZONE");
int lastZone;
int currentZone = 1;

/// calculate ave
//
float aveBR=0;
float sumBR = 0;
float storedValBR[] = {0, 0}; // for sums
float[] storedArrayBR;
int storedArrayCount = 3; // number of values to average
int countBR = 0;
int br = 0;

int zeroBreathes = 30;
boolean putDownGlasses = false;
boolean shouldBlackout = false;

void setup() {

  // start oscP5 first, listening for incoming messages at port 12000
  oscP5 = new OscP5(this, 12000);


  // Keystone will only work with P3D or OPENGL renderers,
  // since it relies on texture mapping to deform
  size(1280, 720, P3D);

  HUDFont = createFont("Roboto-Bold", HUDtextSize);
  HUDArrowFont = createFont("Roboto-Thin", 10); // font size can be changed in code

  ks = new Keystone(this);
  surface = ks.createCornerPinSurface(cornerPinX, cornerPinY, 20);
  offscreen = createGraphics(cornerPinX, cornerPinY, P3D);
  offscreen.textFont(HUDFont);


  ks.load();

  // get start zone from local env
  if (null != thisHostsZone) {
    currentZone = Integer.parseInt(thisHostsZone);
  }

  setupCurrentZone();

  storedArrayBR= new float[storedArrayCount]; // for counting average set
  return;
}

void movieEvent(Movie m) {
  m.read();
}

void tearDown() {
  if (DEBUG) println("tearing down zone.");

  if (myMovie != null)
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

void setupBlackout() {

  if (DEBUG) println("blackout");

  blackout.start();

  currentZone = 6;
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
  case 6:
    setupBlackout();
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
  case 6:
    drawBlackout();
    return;
  }

  println("ERR: setup a non-existant Zone: " + zone);
}


void draw() {
  background(0);

  if (shouldBlackout) { 
    return;
  }

  // smoothing the stress value changes
  smoothStressVal += (stressVal - smoothStressVal) * 0.1; // analog stress values
  smoothStressIntensity += (stressIntensityVal() * 40 - smoothStressIntensity) * 0.1; // 3 states of stress
  //println("stressVal " + stressVal + "stressIntensityVal " + stressIntensityVal());

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

int stressIntensityVal() {
  // maps number of dancers from 1-5 based on stress values
  return (int) map(stressVal, 0, 101, 0, 3);
}

void drawZone1() {
  zone1.draw();
}

void drawZone2() {
  zone2.draw();
}

void drawZone3() {
  zone3.draw();
}

void drawZone4() {
  zone4.draw();
}

void drawZone5() {
  zone5.draw();
}

void drawBlackout() {
  blackout.draw();
}

boolean needToWait() {
  return millis() < (lastImapactTime + impactWaitDuration);
}



void genBreatheRandom() {

  longRangeVal = (int)random(longBR1, longBR2);
  shortRangeVal = (int)random(shortBR1, shortBR2);

  OSCValues = new int[][] 
    {{shortRangeVal, longRangeVal}, 
    {longRangeVal, shortRangeVal}, 
    {shortRangeVal, longRangeVal}, 
    {longRangeVal, shortRangeVal}, 
    {longRangeVal, shortRangeVal}};


  return;
}

void genHrRandom() {
  trueHR = (int)random(75, 90);
  return;
}

void genBrainRandom() {
  trueBrainVal = (int)random(150, 300);
  return;
}

void oscEvent(OscMessage theOscMessage) {
  // print(" typetag:" + theOscMessage.typetag());
  // println(" addrpattern: " +theOscMessage.addrPattern());

  //trueBrainVal, trueBreatheVal, trueHR

  if (theOscMessage.checkAddrPattern("/impact/1/1")) {

    // start
    println(" START");
    lastImapactTime = millis();
    genHrRandom();
    genBrainRandom();
    genBreatheRandom();
    stressVal = moments[currentZone-1][0];
    trueBreatheVal = OSCValues[currentZone-1][0];
    shouldBlackout = false;
  }

  if (theOscMessage.checkAddrPattern("/impact/1/2")) {

    // impact
    println(" IMPACT");
    lastImapactTime = millis();
    genHrRandom();
    genBrainRandom();
    genBreatheRandom();
    stressVal = moments[currentZone-1][1];
    trueBreatheVal = OSCValues[currentZone-1][1];
    shouldBlackout = false;
  }

  if (theOscMessage.checkAddrPattern("/impact/1/3")) {

    // blackout
    println(" BLACKOUT");
    shouldBlackout = true;
  }


  if (theOscMessage.checkAddrPattern("/data")) {
    int hr = theOscMessage.get(0).intValue();
    int brain = theOscMessage.get(1).intValue();
    int breathe = theOscMessage.get(2).intValue();

    if (hr != 0)
      trueHR = hr;

    if (brain != 0)
      trueBrainVal = brain;

    if (breathe !=0 ) { 
      if (breathe > shortBR1) { // only take breathe values of over 500
        trueBreatheVal = breathe;
      }
      zeroBreathes = 0; // captures count of non-zero
      putDownGlasses = false;
    } else { 
      zeroBreathes++;
      if (zeroBreathes > 30 ) {
        if (!needToWait()) {
          putDownGlasses = true;
          //println ("put down ");
          trueBrainVal=0;
          trueBreatheVal=0;
          trueHR=0;
          aveBR=0;
        }
      }
    }

    println ("BW " + trueBrainVal + ", BR " + trueBreatheVal + ", HR " + trueHR);

    // sums pairs of breathe values
    /*
    float newBRFromGlass = (float)trueBreatheVal; // trueBR
     //AddNewValue(newBRFromGlass);
     
     /// takes a running average of two values coming in
     
     if (-1 == AddTwoValues(newBRFromGlass)) {
     // nothing, too many zeros
     } else {
     println("i got the sum" + sumBR);
     sumTwoBR = sumBR;
     }
     */

    // to average across a fixed array collection of values
    if (countBR > 0) { //calculate first ave
      aveBR = sumBR / countBR;
    }


    /// for weighted average

    // float multiplier = 2/(countBR + 1);
    //float EMA_BR = (newBRFromGlass - aveBR) * multiplier + aveBR;
    // println("count: " + countBR + " new value: " +  newBRFromGlass + " proper average: " + aveBR);

    if (!needToWait()) {
      stressVal = breathStressMapping();
    }
  }

  for (int i = 0; i < oscAddr.length; i++) {

    // if (theOscMessage.checkAddrPattern(oscAddr[i])==true) {
    if (theOscMessage.checkAddrPattern( "/Stress/s1")==true) {
      stressVal = (int)theOscMessage.get(0).floatValue();
      //stressIntensityVal();
      println("target stress:" + stressVal);
      return;
    }
  }

  // check message for zone switch address
  for (int j = 0; j < oscZoneAddr.length; j++) {

    if (theOscMessage.checkAddrPattern(oscZoneAddr[j])) {
      float value = theOscMessage.get(0).floatValue();
      //println(value);
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

void AddNewValue(float valBR) {
  if (countBR < storedArrayBR.length) {
    //array is not full yet
    storedArrayBR[countBR++] = valBR;
    sumBR += valBR;
  } else {
    sumBR -= storedArrayBR[br];
    storedArrayBR[br] = valBR;
    sumBR += valBR;
    br = br+1;
    br = br % storedArrayBR.length;
  }
}


float AddTwoValues(float valBR) {
  storedValBR[br] = valBR;
  /*
  if (1500 < abs(storedValBR[0] - storedValBR[1]) ) {
   return -1; 
   }
   */
  sumBR =storedValBR[0] + storedValBR[1]; // takes the running sum
  br = br+1;
  br = br % 2;

  if (storedValBR[0] != 0 && storedValBR[1] != 0) {

    //println("values Br" + valBR +"sum Br" + sumBR);

    for (int i = 0; i < storedValBR.length; i++) {
      //sumBR =storedValBR[0] + storedValBR[1]; // takes a sum in new pairs
      storedValBR[i] = 0;
      //println("values Br" + storedValBR[i]);
    }
    return sumBR;
  } else {
    return -1;
  }
}

int breathStressMapping() {
  if (trueBreatheVal > longBR1) { // low stress val, meaning long breath
    return 15;
  } else if (trueBreatheVal > medBR1) {
    return 50;
  } else {
    return 80;
  }
}
/*
int breathStressMapping() {
 if (sumTwoBR >6000) {
 return 15;
 } else if (sumTwoBR > 3000) {
 return 50;
 } else {
 return 80;
 }
 }
 */


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
  case '6':
    tearDown();
    setupBlackout();
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
    stressVal = 60;
    break;
  case 't':
    stressVal = 75;
    break;
  case 'y':
    stressVal = 100;
    break;

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

  offscreen.textSize(HUDtextSize);

  offscreen.fill(255);
  offscreen.noStroke();
  offscreen.textFont(HUDFont);

  offscreen.text("Analysis".toUpperCase(), textXPer * movX, (textYPer - 0.02) * movY);

  for (int i = 0; i < textDotNumber; i++) {
    offscreen.ellipse(textXPer * movX + i * 10, textYPer * movY, 3, 3);
  }

  offscreen.text("BRAIN WAVES", textXPer * movX, (textYPer + 0.05) * movY);
  offscreen.text(trueBrainVal, (textXPer + numSpacing) * movX, (textYPer + 0.05) * movY);

  offscreen.text("RESPIRATION", textXPer * movX, (textYPer + 0.10) * movY);
  offscreen.text((int)trueBreatheVal, (textXPer + numSpacing) * movX, (textYPer + 0.10) * movY);

  offscreen.text("HEART RATE", textXPer * movX, (textYPer + 0.15) * movY);
  offscreen.text(trueHR, (textXPer + numSpacing) * movX, (textYPer + 0.15) * movY);

  return;
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
  //println("timer " + beginStressManagement);
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