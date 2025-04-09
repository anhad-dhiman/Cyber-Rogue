// SecurityCamera class extends Obstacle
class SecurityCamera extends Obstacle {
  float rotationAngle;
  float rotationSpeed;
  float viewAngle;
  float viewDistance;
  
  SecurityCamera(float x, float y) {
    super(x, y);
    rotationAngle = 0;
    rotationSpeed = 0.02;
    viewAngle = PI/4; // 45 degrees
    viewDistance = 200;
  }
  
  void update() {
    if (isActive) {
      // Rotate back and forth
      rotationAngle = sin(frameCount * rotationSpeed) * PI/2; // -90 to 90 degrees
      
      // Check if player is in view
      checkPlayerInView();
    }
  }
  
  void checkPlayerInView() {
    // Calculate angle to player
    PVector toPlayer = PVector.sub(player.position, position);
    float angleToPlayer = atan2(toPlayer.y, toPlayer.x);
    
    // Normalize angle difference
    float angleDiff = abs(angleToPlayer - rotationAngle);
    while (angleDiff > PI) angleDiff = TWO_PI - angleDiff;
    
    // Check if player is in view cone and not hiding
    if (angleDiff < viewAngle/2 && toPlayer.mag() < viewDistance && !player.isHiding) {
      player.detectDrone();
      
      // Alert nearby drones
      for (Drone drone : drones) {
        if (PVector.dist(drone.position, position) < 150) {
          drone.state = DroneState.PURSUING;
        }
      }
    }
  }
  
  void display() {
    // Draw camera mount
    fill(50);
    noStroke();
    rect(position.x - 5, position.y, 10, 20);
    
    // Draw camera body
    pushMatrix();
    translate(position.x, position.y);
    rotate(rotationAngle);
    
    fill(70);
    stroke(100);
    ellipse(0, 0, 15, 15);
    rect(0, 0, 20, 10);
    
    // Draw lens
    fill(0);
    ellipse(10, 0, 8, 8);
    
    // Draw view cone (for debugging)
    if (isActive) {
      noFill();
      stroke(255, 0, 0, 50);
      arc(0, 0, viewDistance * 2, viewDistance * 2, -viewAngle/2, viewAngle/2);
    }
    
    popMatrix();
  }
  
  void activate() {
    isActive = true;
  }
  
  void deactivate() {
    isActive = false;
  }
}
