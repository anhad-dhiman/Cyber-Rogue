// Environment class for background elements
class Environment extends GameObject {
  color envColor;
  
  Environment(float x, float y) {
    super(x, y);
    envColor = color(30, 40, 50);
  }
  
  void update() {
    // Most environment objects don't need updates
  }
  
  void display() {
    fill(envColor);
    noStroke();
    rect(position.x, position.y, size, size);
  }
}
