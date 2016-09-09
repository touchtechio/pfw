/* 
 this sketch has the rose staying in the middle of the screen
 moving towards and away from the viewer
 the target crosshair circles around the rose depending on stress levels
 the more focused the wearer, the closer the target gets to the rose
 this can be controlled via OSC slider or keypress 1,2
 */

/// Keystoning
import deadpixel.keystone.*;

Keystone ks;
CornerPinSurface surface;

PGraphics offscreen;
int cornerPinX = 1280;
int cornerPinY = 720;

/// moving arrow object
TargetArrow arrow; 
float arrowPosX;
float arrowPosY;

float circleX;
float circleY;

float theta = TWO_PI;
/// oscillator array

Oscillator[] oscillators = new Oscillator[1];

///
import processing.video.*;

/// OSC
import oscP5.*;
import netP5.*;
OscP5 oscP5;
NetAddress myRemoteLocation;
float stressVal;

Movie myMovie;
String movieNames[] = {"rose4.mp4"};
Movie Movies[] = {myMovie};
int moviePlaying = 0;
int movX = 1280;
int movY = 720;
float textXPer = 0.7;
float textYPer = 0.7;

int videoScale = 3; // determines pixel size if drawing pixels

int xstart;
int ystart;
int xend;
int yend;
int centerPtX;
int centerPtY;
int pixelW;
int rate = 100; // set this for step up and down

float  ct = cos(PI/9.0);
float  st = sin(PI/9.0); 

/// determines speed of rose motion
float dxtheta_low = 0;//-0.012; //old -0.009
float dxtheta_high = 0;//0.012;
float dytheta_low = 0;//-0.01; //old -0.004
float dytheta_high = 0;//0.01;

PImage crossHair;
float crossPosX; 
float crossPosY;
int circlePoints = 160;
int textPoints = 75;
float thetaText = TWO_PI / (float)textPoints ; // get the angle for each point

// set the movie speed to a variable
float speed = 5.0;

PFont font;

boolean DEBUG = true;

void setup() {
  size(1280, 720, P3D);
  //print("frameRate = " + frameRate);

  font = createFont("HelveticaNeue", 15);

  /// keystone 
  ks = new Keystone(this);
  surface = ks.createCornerPinSurface(cornerPinX, cornerPinY, 20);
  // (The offscreen buffer can be P2D or P3D)
  offscreen = createGraphics(cornerPinX, cornerPinY, P3D);
  ks.load();

  // start oscP5, listening for incoming messages at port 12000
  oscP5 = new OscP5(this, 12000);
  // netAddress("device IP", outgoing port)
  myRemoteLocation = new NetAddress("10.24.113.15", 9000);

  myMovie = new Movie(this, movieNames[moviePlaying]); 
  myMovie.loop();

  crossHair = loadImage("crossHair6.png");
  arrow = new TargetArrow(color(255));

  // initialize oscillator
  for (int i = 0; i < oscillators.length; i++) {
    oscillators[i] = new Oscillator(dxtheta_low, dxtheta_high, dytheta_low, dytheta_high);
  }
}


void movieEvent(Movie m) {
  m.read();
}

void draw() {
  background(0);

  myMovie.speed(speed);
  //speed += 1.0;
  // Convert the mouse coordinate into surface coordinates
  // this will allow you to use mouse events inside the 
  // surface from your screen. 
  //PVector surfaceMouse = surface.getTransformedMouse();

  // Draw the scene, offscreen
  offscreen.beginDraw();
  offscreen.background(0);

  //offscreen.strokeWeight(5);
  /// this is the cursor to adjust the keystoning, should stay hidden unless can't see mouse
  //offscreen.ellipse(surfaceMouse.x, surfaceMouse.y, 75, 75);
  //offscreen.ellipse(mouseX, mouseY, 75, 75);

  //// if just want movie to play
  //image(myMovie, 0, 0, 1280, 780);

  offscreen.pushMatrix();

  //myMovie.loadPixels();

  for (int i = 0; i < oscillators.length; i++) {
    oscillators[i].oscillate();
    oscillators[i].display(0, 0);
  }
  offscreen.popMatrix();

  //offscreen.image(myMovie, 0, 0);
  drawCrossHair();
  /// set position of arrow in relation to crosshair

  arrowPosX = crossPosX - 70; // X pos fixed
  arrowPosY = crossPosY + 90 + updateArrowScaleUpAndDown (); // y pos moved up and down

  radialArrow();
  
    thetaText -= 0.01;
  //popMatrix();
  displayStressData();

  if (DEBUG) {
    println("framRate " + frameRate);
    offscreen.fill(255);
    offscreen.textSize(15);
    offscreen.text("frameRate " + (int)frameRate, .7 * movX, 0.1 * movY);
    if (keyPressed) {
      println("time" + myMovie.time());// if want to see timestamp of while movie plays
    }
  }

  offscreen.translate(cornerPinX/2, cornerPinY/2);
  offscreen.endDraw();

  // render the scene, transformed using the corner pin surface
  surface.render(offscreen);
}

void oscEvent(OscMessage theOscMessage) {
  /* check if theOscMessage has the address pattern we are looking for. */
  print(" typetag:" + theOscMessage.typetag());
  println(" addrpattern: "+theOscMessage.addrPattern());

  if (theOscMessage.checkAddrPattern("/Stress/s1")==true) {
    stressVal = theOscMessage.get(0).floatValue();
    if (stressVal < 10) {
      speed = 1.0;
      myMovie.jump(30.5);
    } else {
      speed = 3.0;
    }
    println("stress = " +stressVal);
    return;
  }
}

void drawMoviePixels() {
  // Begin loop for columns
  for (int i = 0; i < myMovie.width; i +=videoScale) {
    // Begin loop for rows
    for (int j = 0; j < myMovie.height; j +=videoScale) {

      // Looking up the appropriate color in the pixel array
      int loc = i + j * myMovie.width;
      color c = myMovie.pixels[loc];
      offscreen.fill(c);
      offscreen.noStroke();
      //stroke(0);
      // to make the black parts transparent, only draw colors that are not black
      // 24-bit color has 16777216 colors (2^8)^3
      if (c > -16777216) {
        offscreen.rect(i, j, videoScale, videoScale);
      }
    }
  }
}

/// draw moving arrow on the right
void radialArrow() {
  //float dataRate = 1 + (float)updateFlatUpAndDown()/rate/2;
  float distLine = 1.05;
  for (int i = 31; i < 50; i ++) {
    offscreen.pushMatrix();
    stroke(255);
    //translate(firstValue * 1280, secondValue * 780);
    offscreen.translate(crossPosX + crossHair.width/2, crossPosY + crossHair.height/2);
    int r = 200;
    float r2 = (float)r * distLine;
    float theta = TWO_PI / (float)circlePoints ; // get the angle for each point

    // circle with line points
    offscreen.line(sin(theta * i)*r, cos(theta * i) * r, sin(theta * i)*r2, cos(theta *i) * r2);
    offscreen.rotate(0.3 * sin(thetaText * 5));
    offscreen.line(r * 1.15, 15, r * 1.15,  - 15);
    offscreen.beginShape();
    offscreen.vertex(r * 1.15, -8);
    offscreen.vertex(r * 1.1, 0);
    offscreen.vertex(r * 1.15, 8);
    offscreen.endShape();
    offscreen.text("hello", r * 1.2, 3);
    offscreen.line(r * 1.3, -20, r * 1.3, - 28);
    offscreen.line(r * 1.3, 20, r * 1.3, 28);
    offscreen.popMatrix();
  }
}

// using this to move rose on the depth axis;
int updateScatterScaleUpAndDown () {
  //int scale = ((int)millis() % 21);
  int scale = ( frameCount % 800);

  if (scale < 400) {
    return (400 - scale);
  }
  return (scale - 399);
}

// using this to move arrow on left of target up and down
int updateArrowScaleUpAndDown () {
  //int scale = ((int)millis() % 21);
  int scale = ( frameCount % 200);

  if (scale < 100) {
    return (100 - scale);
  }
  return (scale - 99);
}


int updateScaleUpAndDown () {
  //int scale = ((int)millis() % 21);
  int scale = ((int)stressVal % 50);

  if (scale < 25) {
    return (25 - scale);
  }
  return (scale - 24);
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

  case '1':
    // saves the layout
    stressVal = 80;
    speed = 3.0;
    myMovie.jump(0.0);
    return;

  case '2':
    // saves the layout
    stressVal = 0;
    speed = 1;
    myMovie.jump(30.5);
    //myMovie.loop();
    return;
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

void drawCrossHair() {
  float r = 10 + stressVal; // radius distance to rose
  circleX = sin(theta/12)* r; 
  circleY = cos(theta/12)* r;
  theta += TWO_PI/36; // angle increase around rose
  //println("theta " + theta);

  /// set position of crosshair to OSC Stress data but rotating around the rose;
  crossPosX = oscillators[0].rosePosX + 350 + circleX * 5; // check this out
  crossPosY = oscillators[0].rosePosY  + 200 + circleY * 2; // check this out

  offscreen.pushMatrix();
  //offscreen.scale(0.5);
  //offscreen.translate(-crossHair.width/2, -crossHair.height/2);
  offscreen.image(crossHair, crossPosX, crossPosY);//, 500, 320);
  offscreen.popMatrix();

  /// draw moving arrow left of crosshair
  offscreen.pushMatrix();
  // position moving arrow in relation to cross hair
  offscreen.translate(arrowPosX, arrowPosY);
  arrow.display((int) frameRate);

  //arrow.display(updateArrowScaleUpAndDown ());
  offscreen.popMatrix();
}