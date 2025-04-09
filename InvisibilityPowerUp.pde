// Implementation of a PowerUp - InvisibilityPowerUp
class InvisibilityPowerUp implements PowerUp {
  float x, y;
  float size;
  boolean collected;
  int duration;
  
  InvisibilityPowerUp(float x, float y) {
    this.x = x;
    this.y = y;
    this.size = 20;
    this.collected = false;
    this.duration = 300; // 5 seconds at 60fps
  }
  
  void collect() {
    collected = true;
    applyEffect();
  }
  
  void display() {
    if (!collected) {
      // Draw power-up
      noStroke();
      fill(neonBlue, 100 + 50 * sin(frameCount * 0.1));
      ellipse(x, y, size, size);
      
      // Draw icon
      stroke(255);
      noFill();
      ellipse(x, y, size * 0.6, size * 0.6);
      line(x - size/4, y, x + size/4, y);
      line(x, y - size/4, x, y + size/4);
    }
  }
  
  boolean isCollected() {
    return collected;
  }
  
  void applyEffect() {
    // Make player temporarily invisible to drones
    // This would need to be implemented in the main game loop
    println("Invisibility power-up collected!");
  }
  
  int getDuration() {
    return duration;
  }
}
