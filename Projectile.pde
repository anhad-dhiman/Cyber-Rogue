// Projectile class
class Projectile {
  PVector position;
  PVector velocity;
  float size;
  boolean isPlayerProjectile;
  color projectileColor;
  boolean isGroundProjectile;
  float lifespan;
  
  Projectile(float x, float y, PVector target, boolean isFromPlayer) {
    position = new PVector(x, y);
    PVector direction = PVector.sub(target, position);
    direction.normalize();
    velocity = direction.mult(10);
    size = 10;
    isPlayerProjectile = isFromPlayer;
    projectileColor = isPlayerProjectile ? neonBlue : neonOrange;
    isGroundProjectile = false;
    lifespan = 120; // frames before despawning
  }
  
  void update() {
    // Update position
    position.add(velocity);
    
    // Ground projectiles stay on the ground
    if (isGroundProjectile) {
      position.y = height - 110;
    }
    
    // Reduce lifespan
    lifespan--;
  }
  
  void display() {
    float flickerIntensity = map(sin(frameCount * 0.5), -1, 1, 0.7, 1);
    
    if (isGroundProjectile) {
      // Ground energy wave
      fill(projectileColor, 150 * flickerIntensity);
      noStroke();
      beginShape();
      for (int i = 0; i < 8; i++) {
        float angle = map(i, 0, 8, 0, TWO_PI);
        float xOffset = cos(angle + frameCount * 0.2) * size;
        float yOffset = sin(angle + frameCount * 0.2) * 5;
        vertex(position.x + xOffset, position.y + yOffset);
      }
      endShape(CLOSE);
    } else {
      // Standard projectile with trail
      noStroke();
      for (int i = 0; i < 5; i++) {
        float alpha = map(i, 0, 5, 200, 50);
        fill(projectileColor, alpha * flickerIntensity);
        ellipse(position.x - velocity.x * i * 0.15, 
                position.y - velocity.y * i * 0.15, 
                size - i, size - i);
      }
      
      // Glow effect
      fill(projectileColor, 100 * flickerIntensity);
      ellipse(position.x, position.y, size * 2, size * 2);
    }
  }
  
  boolean isDead() {
    return lifespan <= 0;
  }
}
