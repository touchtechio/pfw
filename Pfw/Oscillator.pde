class Oscillator {   

  // Two angles
  float xtheta;  
  float ytheta;
  // Increment value for both angles  
  float dxtheta;
  float dytheta;
  float dxtheta_low;
  float dxtheta_high;
  float dytheta_low;
  float dytheta_high;
  float x;
  float y;
  float rosePosX;
  float rosePosY;

  Oscillator(float dxtheta_low, float dxtheta_high, float dytheta_low, float dytheta_high) {   
    xtheta = 0;  
    ytheta = 0;  
    // Start randomly
    checkValues();
    dxtheta = random(dxtheta_low, dxtheta_high);
    dytheta = random(dytheta_low, dytheta_high);
  }   

  void oscillate(float stressLevel) {
    // Increment angles   
    xtheta += dxtheta * stressLevel; 
    ytheta += dytheta * stressLevel;
  }   

  void display(float roseStartX, float roseStartY) {   
    // Map results of sine / cosine to width and height of window to
    // give oscillator motion
    // movX * 0.1 determins amount of movement across the screen

    x = (sin(xtheta)) * movX * 0.1;   
    y = (cos(ytheta)) * movX * 0.01;
    //x = 0;
    //y = 0;
    stroke(0);
    fill(175, 100);
    /// draw rose film
    // offscreen.ellipse(x,y,64,64); 
    rosePosX = x + roseStartX ; 
    rosePosY = y + roseStartY ;
    //offscreen.translate(stressVal * sin(updateRoseSpaz()),  stressVal/2 * cos(updateRoseSpaz()), updateRoseZoom ()- 400);
    //offscreen.translate(0, 0, (updateRoseZoom()- 400)* (int)stressVal/100);
    offscreen.translate(50,0,0);

    //println("roseZoom "+updateRoseZoom());
    //drawMoviePixels();

    offscreen.image(myMovie, rosePosX, rosePosY, 1280, 720);
    //println( rosePosX ,  rosePosY );
    //println("mouse " + mouseX, mouseY);
    //println("dist " + dist(x, y, mouseX, mouseY));
  }
  void checkValues() {
    if (dist(x, y, mouseX, mouseY) < 315 && dist(x, y, mouseX, mouseY) > 285) {
      xtheta = 0;
      ytheta = 0;
      //println("dist " + dist(x, y, mouseX, mouseY));
      return;
    }
  }

  int updateRoseZoom () {
    //int scale = ((int)millis() % 21);
    int scale = (frameCount % 200) ;

    if (scale < 100) {
      return (100 - scale);
    }
    return (scale - 99);
  }

  float roseZoomScale() {
    return map(stressVal, 0, 100, 1.0, 1.5);
  }
  int updateRoseSpaz () {
    //int scale = ((int)millis() % 21);
    if (stressVal !=0) {
      int spazRate = (int) 400;
      int scale = (frameCount % spazRate);

      if (scale < spazRate/2) {
        return ((int) spazRate/2 -  scale);
      }
      return (scale - (spazRate/2 - 1));
    } else { 
      return 0;
    }
  }
}   