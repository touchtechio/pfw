public class TargetArrow {
  color fillC;
  int strokeW;
  int data;


  TargetArrow(color tempC) {
    fillC = tempC;
    //strokeWeight(strokeW);
    stroke(fillC);
    //pixelScale = tempScale;
  }

  void display(int tempData) {

    data = tempData;
    offscreen.noFill();
    offscreen.strokeWeight(2);
    offscreen.stroke(fillC);
    offscreen.beginShape();
    offscreen.vertex(0, 0);
    offscreen.vertex(40, 0);
    offscreen.vertex(50, 10);
    offscreen.vertex(40, 20);
    offscreen.vertex(0, 20);
    offscreen.endShape(CLOSE);
    offscreen.fill(255);
    offscreen.textSize(13);
    
    offscreen.text(data, 8, 15);
    //offscreen.text(myMovie.time(), 8, 15);
  }

}