// stress value affects 3 things - oscillator input parameter, radius of crosshair, speed of arrows
// to switch between analog stress values and 3 stress states - smootStressVal or smoothStressIntensity

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
  float crossPosX; 
  float crossPosY;

  boolean roseBloom = false;
  float bloomStart;
  float roseTimer;
  float bloomCycle;
  boolean roseMovieAutoBloom = false;

  TargetArrow arrow;
  int arrowSpeed;
  float crossHairScale = 2;
  float oscSpeed = 5.0; // smaller number means faster, it's a divisor

  float quickBloomCycle = 2500;
  float fullBloomCycle = 6700;

  //float movieSpeeds[] = {1.0, 1.5, 2.0};

  void start() {
    if (DEBUG) println("start zone 1");
    arrow = new TargetArrow(color(255));
    arrow.start();

    // initialize oscillator
    for (int i = 0; i < oscillators.length; i++) {
      oscillators[i] = new Oscillator(-0.012, 0.012, -0.01, 0.01); //starting speed of oscillator
    }

    return;
  }

  void draw() {

    offscreen.pushMatrix();
    checkRoseBloom(); //check to see if rose has bloomed, if it has move arrow

    offscreen.stroke(255);

    for (int i = 0; i < oscillators.length; i++) {
      //oscillators[i].oscillate(smoothStressVal/20); // oscillator speed changes as multiple of smoothStressVal
      oscillators[i].oscillate(smoothStressIntensity/oscSpeed); // oscillator speed changes as multiple of smoothStressVal
      oscillators[i].display(0, 0);
    }
    offscreen.popMatrix();

    //offscreen.image(myMovie, 0, 0);
    drawCrossHair();
    /// set position of arrow in relation to crosshair

    /// draw the moving curved arrow to right of target;
    resetBloom();
    resetBloomCycle();

    // smooths the movement between the 3 zone values


    displayStressData();
  }

  /// draw moving arrow on the right

  void drawCrossHair() {
    //float r = smoothStressVal; // radius distance to rose
    float r = smoothStressIntensity;
    /*
    float crossSpaz;
     if (smoothStressVal > 20) {
     crossSpaz = random(r-smoothStressVal/10, r);
     } else {crossSpaz = r;}
     
     circleX = sin(theta/12)* crossSpaz; 
     circleY = cos(theta/12)* crossSpaz;
     */
    circleX = sin(theta/12) * r; 
    circleY = cos(theta/12) * r;
    theta += TWO_PI/36; // angle increase around rose
    //println("theta " + theta);

    /// set position of crosshair to OSC Stress data but rotating around the rose;
    crossPosX = oscillators[0].rosePosX + 100 + circleX * 4; // check this out
    crossPosY = oscillators[0].rosePosY + 60 + circleY * 3; // check this out

    //// new changes
    int arrowSpeed = (int)smoothStressVal/5;
    offscreen.pushMatrix();

    offscreen.translate(crossPosX, crossPosY);
    offscreen.scale(crossHairScale);
    //  arrow.placeCrosshair();
    arrow.displayChevronArrow((int)frameRate, arrowSpeed);
    arrow.displayRadialArrow(arrowSpeed);

    //arrow.display(updateArrowScaleUpAndDown ());
    offscreen.popMatrix();
  }

  void checkRoseBloom() {

    if (stressIntensityVal() == 0 && !roseBloom) {
      println("stressed");
      //myMovie.jump(stressMovieVal[0][3]);
      myMovie.jump(stressMovieVal[currentZone-1][0]); // jump to rose bloom point
      roseBloom = true;
      bloomStart = millis();

      println(roseMovieAutoBloom);
    } else if (!roseMovieAutoBloom && !roseBloom) {
      myMovie.jump(stressMovieVal[currentZone-1][1]); // jump to half bloom point to start loop
      roseMovieAutoBloom = true;
      bloomCycle = millis();
    }
    return;
  }

  // using this to move arrow on left of target up and down

  void resetBloom() {
    if (roseBloom) {
      if (millis() > bloomStart + fullBloomCycle) {
        //myMovie.jump(4.0); // jump time to rose close;

        roseBloom = false;
      }
    }
  }

  void resetBloomCycle() {
    if (roseMovieAutoBloom) {
      if (millis() > bloomCycle + quickBloomCycle) {
        roseMovieAutoBloom = false;
      }
    }
  }
}