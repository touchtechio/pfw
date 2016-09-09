import deadpixel.keystone.*;
Keystone ks;
CornerPinSurface surface;
PGraphics offscreen;
int cornerPinX = 1280;
int cornerPinY = 720;

import processing.video.*;
Movie myMovie;
Movie myMovie2;
int videoScale = 10;
int cols, rows;

int movX;
int movY;
PImage pixelMan;
PImage hotel;

BlackPixels blackPixels;
BlackPixels purplePixels;

float textXPer = 0.7;
float textYPer = 0.7;

boolean DEBUG = true;  // determines whether to data on screen

PFont font;

float scaleNumber;

void setup() {
  size(1280, 720, P3D);
  
  font = createFont("HelveticaNeueu", 15);
  
  ks = new Keystone(this);
  surface = ks.createCornerPinSurface(cornerPinX, cornerPinY, 20);
  offscreen = createGraphics(cornerPinX, cornerPinY, P3D);
  //ks.load();
  
  myMovie = new Movie(this, "dancing2.mp4");
  myMovie2 = new Movie(this, "dancing3.mp4");
  
  myMovie.loop();
  myMovie2.loop();

  // changes speed of pixels appearing
  frameRate(10);
  //myMovie.speed(2.0); 
  movX = myMovie.width;
  movY = myMovie.height;

  // BlackPixels(color tempC, int tempScale)
  blackPixels = new BlackPixels(color(0), 40);
  purplePixels = new BlackPixels(color(250, 98, 237), 40);
}


void movieEvent(Movie m) {
  m.read();
}

void draw() {
  //// scale of pixels here. To replace with biosensing data
  
  // videoScale = updateFlatScaleUpAndDown();
  background(100);
  offscreen.beginDraw();
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
  offscreen.translate(cornerPinX/2, cornerPinY/2);
  offscreen.endDraw();
  surface.render(offscreen);
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
        offscreen.rect(i - myMovie.width/2, j - myMovie.height/2, videoScale, videoScale);
      }
    }
  }
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