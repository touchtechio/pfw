class BlackPixels {
  color c;
  int pixelScale;
  int scatter;

  BlackPixels(color tempC, int tempScale) {
    c = tempC;
    pixelScale = tempScale;
    
  }

  void display(int tempScatter) {
    scatter = tempScatter;
    for (int i = 0; i < movX; i +=pixelScale * tempScatter) {
      // Begin loop for rows
      for (int j = 0; j < movY; j +=pixelScale) {
        int pixelSelector = pixelScale * (int)random(5);
        // Looking up the appropriate color in the pixel array
        fill(c);
        //stroke(0);
        rect(i + pixelSelector, j, pixelScale, pixelScale);
      }
    }
  }
}