// Building class for background elements
class Building extends GameObject {
  float width;
  float height;
  color buildingColor;
  
  Building(float x, float y, float w, float h) {
    super(x, y);
    this.width = w;
    this.height = h;
    buildingColor = color(20, 25, 35);
  }
  
  void update() {
    // Buildings don't need to update in this implementation
  }
  
  void display() {
    // Draw building
    noStroke();
    fill(buildingColor);
    rect(position.x, position.y, width, height);
    
    // Draw windows
    fill(neonBlue, random(50, 150));
    for (float x = position.x + 10; x < position.x + width - 10; x += 15) {
      for (float y = position.y + 10; y < position.y + height - 10; y += 20) {
        if (random(1) > 0.3) {
          rect(x, y, 10, 15);
        }
      }
    }
    
    // Draw roof details
    fill(30, 35, 45);
    rect(position.x, position.y, width, 5);
    
    // Draw neon sign occasionally
    if (random(1) > 0.7) {
      fill(neonPink, 200 * neonFlicker);
      rect(position.x + width/4, position.y + 30, width/2, 15);
    }
  }
}
