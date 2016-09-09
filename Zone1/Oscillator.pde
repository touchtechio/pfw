// Learning Processing
// Daniel Shiffman
// http://www.learningprocessing.com

// Exercise 13-6: Encapsulate Example 13-6 into an Oscillator object. Create an array 
// of Oscillators, each moving at diff erent rates along the x and y axes. Here is some code for the 
// Oscillator class to help you get started.  

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

  void oscillate() {
    // Increment angles   
    xtheta += dxtheta;
    ytheta += dytheta;
  }   

  void display(float roseStartX, float roseStartY) {   
    // Map results of sine / cosine to width and height of window to give oscillator motion
    
    //x = abs((sin(xtheta)) * movX * 0.4);   
    //y = abs((cos(ytheta)) * movY * 0.4);
    x = 0;
    y = 0;
    stroke(0);
    fill(175, 100);
    /// draw rose film
    // offscreen.ellipse(x,y,64,64); 
    rosePosX = x + roseStartX ; 
    rosePosY = y + roseStartY ;
    offscreen.translate(0, 0, updateScatterScaleUpAndDown ()- 400);
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
}   