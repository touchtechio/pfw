

class Zone1 {


  Oscillator[] oscillators = new Oscillator[1];

  /// moving arrow object

  float theta = TWO_PI;

  float arrowPosX;
  float arrowPosY;

  float circleX;
  float circleY;

  float  ct = cos(PI/9.0);
  float  st = sin(PI/9.0); 

  /// determines speed of rose motion
  float dxtheta_low = 0;//-0.012; //old -0.009
  float dxtheta_high = 0;//0.012;
  float dytheta_low = 0;//-0.01; //old -0.004
  float dytheta_high = 0;//0.01;

  float crossPosX; 
  float crossPosY;
  int circlePoints = 160;
  int textPoints = 75;
  float thetaText = TWO_PI / (float)textPoints ; // get the angle for each point

  boolean roseBloom = false;

  TargetArrow arrow;
  PImage crossHair;


  void start() {
    if (DEBUG) println("start zone 1");

    crossHair = loadImage("crossHair6.png");
    arrow = new TargetArrow(color(255));

    // initialize oscillator
    for (int i = 0; i < oscillators.length; i++) {
      oscillators[i] = new Oscillator(dxtheta_low, dxtheta_high, dytheta_low, dytheta_high);
    }

    return;
  }

  void draw() {

    offscreen.pushMatrix();
    checkRoseBloom(); //check to see if rose has bloomed, if it has move arrow
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

    /// draw the moving curved arrow to right of target;
    radialArrow();

    thetaText -= 0.01;
    //popMatrix();
    displayStressData();
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

      // draw triangle indicator
      offscreen.line(r * 1.15, 15, r * 1.15, - 15);
      offscreen.beginShape(); 
      offscreen.vertex(r * 1.15, -8);
      offscreen.vertex(r * 1.1, 0);
      offscreen.vertex(r * 1.15, 8);
      offscreen.endShape();

      offscreen.text("Chalayan", r * 1.2, 3);
      offscreen.line(r * 1.3, -20, r * 1.3, - 28);
      offscreen.line(r * 1.3, 20, r * 1.3, 28);
      offscreen.popMatrix();
    }
  }



  void drawCrossHair() {
    float r = 10 + stressVal; // radius distance to rose
    circleX = sin(theta/12)* r; 
    circleY = cos(theta/12)* r;
    theta += TWO_PI/36; // angle increase around rose
    //println("theta " + theta);

    /// set position of crosshair to OSC Stress data but rotating around the rose;
    crossPosX = oscillators[0].rosePosX + 340 + circleX * 4; // check this out
    crossPosY = oscillators[0].rosePosY  + 230 + circleY * 3; // check this out

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



  // using this to move arrow on left of target up and down
  int updateArrowScaleUpAndDown () {
    //int scale = ((int)millis() % 21);
    int scale = ( frameCount % 200);

    if (scale < 100) {
      return (100 - scale);
    }
    return (scale - 99);
  }

  void checkRoseBloom() {
    if (myMovie.time() > 20.5) {
      if (!roseBloom) {
        stressVal = 10;
        println("bloom");
        roseBloom = true;
      }
      return;
    } else {
    }
  }
}