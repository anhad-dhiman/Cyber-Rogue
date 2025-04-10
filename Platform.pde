// Platform class for level 2
class Platform extends GameObject {
  float w, h;
  
  Platform(float x, float y, float width, float height) {
    super(x, y);
    this.w = width;
    this.h = height;
  }
  
  void update() {
    // Platforms are static, no update needed
  }
  
  void display() {
    noStroke();
    // Create a neon-edged cyberpunk platform
    
    // Main platform
    fill(40);
    rect(position.x, position.y, w, h);
    
    // Neon edge
    stroke(neonBlue, 150 + 50 * sin(frameCount * 0.05));
    strokeWeight(2);
    line(position.x, position.y, position.x + w, position.y);
    
    // Tech details
    fill(20);
    noStroke();
    for (int i = 0; i < w; i += 20) {
      rect(position.x + i, position.y + 5, 10, h - 10);
    }
    
    // Random blinking lights
    for (int i = 0; i < 3; i++) {
      if (random(1) > 0.7) {
        fill(neonPink, random(100, 200));
        rect(position.x + random(w), position.y + h - 5, 3, 2);
      }
    }
  }
}
