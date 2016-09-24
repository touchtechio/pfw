public class TargetArrow {
  color fillC;
  float strokeW = 2.5;
  float thinStrokeW = 1;
  int data;
  int circlePoints = 160;
  int textPoints = 75;
  float thetaText = TWO_PI / (float)textPoints ; // get the angle for each point
  float arrowPosX;
  float arrowPosY;

  PImage crossHair;


  TargetArrow(color tempC) {
    fillC = tempC;
    //strokeWeight(strokeW);
    stroke(fillC);
    //pixelScale = tempScale;
  }

  void start () {
    crossHair = loadImage("crossHair6.png");
  }

  void placeCrosshair() {
    
    offscreen.pushMatrix();
    //offscreen.scale(0.5);
    //offscreen.translate(-crossHair.width/2, -crossHair.height/2);
    offscreen.image(crossHair, 0, 0);//, 500, 320);
    offscreen.popMatrix();
  }

  void displayChevronArrow(int tempData, int arrowSpeed) {

    /// draw moving arrow left of crosshair
    offscreen.pushMatrix();
    // position moving arrow in relation to cross hair
    offscreen.textFont(HUDFont);
    offscreen.textSize(15);
    arrowPosX = - 70; // X pos fixed
    arrowPosY = 90 + updateArrowScaleUpAndDown(arrowSpeed); // y pos moved up and down
    offscreen.translate(arrowPosX, arrowPosY);
    //offscreen.scale(1.2);
    drawChevronArrow(tempData);
    offscreen.popMatrix();
  }

  void drawChevronArrow(int tempData) {

    data = tempData;
    offscreen.noFill();
    offscreen.strokeWeight(strokeW);
    offscreen.stroke(fillC);
    offscreen.beginShape();
    offscreen.vertex(0, 0);
    offscreen.vertex(40, 0);
    offscreen.vertex(50, 10);
    offscreen.vertex(40, 20);
    offscreen.vertex(0, 20);
    offscreen.endShape(CLOSE);
    offscreen.fill(255);


    offscreen.text(data, 8, 15);
    //offscreen.text(myMovie.time(), 8, 15);
  }


  void displayRadialArrow(int arrowSpeed) {

    thetaText -= 0.01;

    //float dataRate = 1 + (float)updateFlatUpAndDown()/rate/2;
    float distLine = 1.05; //linelength

    offscreen.noFill();

    offscreen.pushMatrix();
    offscreen.strokeWeight(strokeW);

    //translate(firstValue * 1280, secondValue * 780);
    offscreen.translate(crossHair.width/2, crossHair.height/2);
    //offscreen.translate(crossPosX , crossPosY );
    int r = 200;
    float r2 = (float)r * distLine;
    float theta = TWO_PI / (float)circlePoints ; // get the angle for each point

    // circle with line points
    for (int i = 31; i < 50; i ++) {
      offscreen.line(sin(theta * i)*r, cos(theta * i) * r, sin(theta * i)*r2, cos(theta *i) * r2);
    }

    // draw arcs
    offscreen.pushMatrix();
    offscreen.translate(25, 0);

    // upper and lower vertical lines
    offscreen.line(0, 120, 0, 145); 
    offscreen.line(0, -120, 0, -145); 

    // left horizontal line and corner
    offscreen.line(-80, 0, -100, 0); 
    offscreen.line(-120, 0, -140, 0); 
    offscreen.line(-140, strokeW/2, -140, -15); //strokeWeight to compensate for square corners

    // right horizontal line and corner
    offscreen.line(80, 0, 140, 0); 
    offscreen.line(140, strokeW/2, 140, -15); 


    // left column of horizontal lines
    int leftLineSpacing = 8;
    offscreen.line(-180, 0, -190, 0); // line below and top of
    for (int i = 0; i < 9; i++) {
      if ((i%4) == 0) {
        offscreen.strokeWeight(strokeW);
        offscreen.line(-180, -i*leftLineSpacing, -195, -i*leftLineSpacing); // line below and top of
        offscreen.line(-180, i*leftLineSpacing, -195, i*leftLineSpacing); // line below and top of
      } else {
         offscreen.strokeWeight(thinStrokeW);

        offscreen.line(-180, -i*leftLineSpacing, -188, -i*leftLineSpacing); // line below and top of
        offscreen.line(-180, i*leftLineSpacing, -188, i*leftLineSpacing); // line below and top of
      }
    }

    // inner box
    for (int i = 0; i < 4; i++ ) {
      offscreen.line(50, 51, 50, 25); // line below and top of
      offscreen.line(51, 50, 25, 50); // line below and top of
      offscreen.rotate(HALF_PI);
    }

    // upper and lower arcs
    offscreen.rotate(radians(32));
    offscreen.arc(0, 0, 200, 200, 0, 2);
    offscreen.rotate(radians(180));
    offscreen.arc(0, 0, 200, 200, 0, 2);

    // upper and lower arcs dashes
    for (int i = 0; i < 10; i ++) {
      offscreen.rotate(radians(10));
      offscreen.arc(0, 0, 180, 180, 0, radians(5));
    }
    offscreen.rotate(radians(75));
    for (int i = 0; i < 10; i ++) {
      offscreen.rotate(radians(10));
      offscreen.arc(0, 0, 180, 180, 0, radians(5));
    }

    offscreen.popMatrix();

    offscreen.rotate(0.3 * sin(thetaText * arrowSpeed));

    // draw triangle indicator
    offscreen.line(r * 1.15, 20, r * 1.15, - 20);
    offscreen.fill(255);
    offscreen.beginShape(); 
    offscreen.vertex(r * 1.15, -8);
    offscreen.vertex(r * 1.1, 0);
    offscreen.vertex(r * 1.15, 8);
    offscreen.endShape();
    
    // Draw chalayan text with little dashed lines
    offscreen.textSize(18);
    offscreen.text("Chalayan", r * 1.2, 7);
    offscreen.line(r * 1.3, -20, r * 1.3, - 30); // line below and top of
    offscreen.line(r * 1.3, 20, r * 1.3, 30);
    offscreen.popMatrix();
  }
  int updateArrowScaleUpAndDown (int arrowSpeed) {
    //int scale = ((int)millis() % 21);
    int scale = (frameCount * arrowSpeed / 2 % 200); // changes arrow speed
    if (scale < 100) {
      return (100 - scale);
    }
    return (scale - 99);
  }
}