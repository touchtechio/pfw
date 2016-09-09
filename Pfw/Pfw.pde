/*
this sketch runs a movie that correlates to levels of stress
 Use OSC buttons or keypress 1,2,3,4 to jump to different states
 */

import deadpixel.keystone.*;
Keystone ks;
CornerPinSurface surface;
PGraphics offscreen;
int cornerPinX = 1280;
int cornerPinY = 720;

import processing.video.*;
Movie myMovie;
String movieNames[] = {"rope3.mp4"};
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

/// OSC
import oscP5.*;
import netP5.*;
OscP5 oscP5;
NetAddress myRemoteLocation;

boolean DEBUG = true; // determines whether to data on screen

PFont font;

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
  // netAddress("device IP", outgoing port)
  myRemoteLocation = new NetAddress("10.175.88.79", 9000);

  myMovie = new Movie(this, movieNames[moviePlaying]);
  myMovie.loop();
}

void movieEvent(Movie m) {
  m.read();
}

void draw() {
  background(0);

  // Convert the mouse coordinate into surface coordinates
  // this will allow you to use mouse events inside the surface from your screen. 
  //PVector surfaceMouse = surface.getTransformedMouse();

  // Draw the scene, offscreen
  offscreen.beginDraw();
  offscreen.background(0);
  offscreen.stroke(255);

  //// show or hide mouse to move keystone points around
  //offscreen.strokeWeight(5);
  //offscreen.ellipse(surfaceMouse.x, surfaceMouse.y, 75, 75);
  // offscreen.ellipse(mouseX, mouseY, 75, 75);

  /// play movie file
  offscreen.image(myMovie, 0, 0, 1280, 720);
  //movieScrubber();
  if (DEBUG) { 
    println("framRate " + frameRate);
    //println("time " + myMovie.time());
    offscreen.textSize(15);
    // offscreen.text("frameRate " + (int)frameRate, .7 * movX, 0.1 * movY);
    offscreen.text("time " + myMovie.time(), .7 * movX, 0.1 * movY);
    displayStressData();
    //println("time "+myMovie.time()); // if want to see timestamp of while movie plays
  }

  offscreen.translate(cornerPinX/2, cornerPinY/2);
  offscreen.endDraw();
  // render the scene, transformed using the corner pin surface
  surface.render(offscreen);
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
  case '1':
    myMovie.jump(stressMovieVal[0]);
    //return;
    break;

  case '2':
    myMovie.jump(stressMovieVal[1]);

    //return;
    break;

  case '3':
    float stress3 = 21.0;
    myMovie.jump(stress3);
    stress3 -= 0.1;
    return;
    //break;

  case'4':
    myMovie.jump(stressMovieVal[3]);
    return;
    //break;
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
  //println(mousePosRatio* myMovie.duration());
}