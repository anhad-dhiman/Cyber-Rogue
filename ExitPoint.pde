class ExitPoint extends GameObject {
  float pulseEffect;
  
  ExitPoint(float x, float y) {
    super(x, y);
    size = 50;
    pulseEffect = 0;
  }
  
  void update() {
    // Pulsating effect
    pulseEffect = sin(frameCount * 0.05) * 10;
  }
  
  void display() {
    // Draw exit portal
    noStroke();
    
    // Outer glow
    for (int i = 3; i > 0; i--) {
      fill(neonBlue, 50 / i);
      ellipse(position.x, position.y, size + pulseEffect + i * 20, size + pulseEffect + i * 20);
    }
    
    // Inner portal
    fill(neonBlue, 150);
    ellipse(position.x, position.y, size + pulseEffect, size + pulseEffect);
    fill(0, 80, 200);
    ellipse(position.x, position.y, (size + pulseEffect) * 0.7, (size + pulseEffect) * 0.7);
    
    // Center
    fill(255);
    ellipse(position.x, position.y, 10, 10);
    
    // Exit text
    fill(255);
    textSize(14);
    textAlign(CENTER);
    text("EXIT", position.x, position.y - size/2 - 10);
  }
}
