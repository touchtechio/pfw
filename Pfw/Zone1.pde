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
  boolean roseMovieAutoBloom = false;

  TargetArrow arrow;
  int arrowSpeed;

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
    //myMovie.loadPixels();
    offscreen.stroke(255);
    
    for (int i = 0; i < oscillators.length; i++) {
      oscillators[i].oscillate(smoothStressVal/30); // oscillator speed changes as multiple of smoothStressVal
      oscillators[i].display(0, 0);
    }
    offscreen.popMatrix();

    //offscreen.image(myMovie, 0, 0);
    drawCrossHair();
    /// set position of arrow in relation to crosshair

    /// draw the moving curved arrow to right of target;
    resetBloom();
    
    //popMatrix();
    displayStressData();
  }

  /// draw moving arrow on the right

  void drawCrossHair() {
    float r = smoothStressVal; // radius distance to rose
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
    crossPosX = oscillators[0].rosePosX + 340 + circleX * 4; // check this out
    crossPosY = oscillators[0].rosePosY + 230 + circleY * 3; // check this out
    
    //// new changes
    int arrowSpeed = (int)smoothStressVal/10;
    offscreen.pushMatrix();
    
    offscreen.translate(crossPosX, crossPosY);
    
    arrow.placeCrosshair();
    arrow.displayChevronArrow((int)frameRate, arrowSpeed);
    arrow.displayRadialArrow(arrowSpeed);
    
    //arrow.display(updateArrowScaleUpAndDown ());
    offscreen.popMatrix();
  }


  void checkRoseBloom() {

    if (smoothStressVal < 10 && !roseBloom) {
      println("stressed");
      //myMovie.jump(stressMovieVal[0][3]);
      myMovie.jump(17.5);
      roseBloom = true;
      bloomStart = millis();
      roseMovieAutoBloom = true;
      println(roseMovieAutoBloom);
      return;
    }
  }

  /*
      myMovie.jump(6.0);
   roseTimer = millis();
   */

  /*
    if (myMovie.time() > 20.5 && myMovie.time() < 36.0 && !roseMovieAutoBloom) {
   smoothStressVal = 8;
   println("bloom");
   roseMovieAutoBloom = true;
   return;
   } else {
   }
   }
   */
   
       // using this to move arrow on left of target up and down
 
  void resetBloom() {
    if (roseBloom) {
      if (millis() > bloomStart + 5000) {
        myMovie.jump(4.0); // jump time to rose close;
        roseMovieAutoBloom = false;
        roseBloom = false;
      }
    }
    /*
    if (millis() > roseTimer + 3000) {
     myMovie.jump(4.0);
     //roseBloom = false;
     }
     }
     */
  }
}