// Robot Villain class
class RobotVillain extends Character {
  color bodyColor;
  float attackCooldown;
  float lastAttackTime;
  int attackPattern;
  boolean isTalking;
  String[] dialogueLines;
  int currentLine;
  float dialogueTimer;
  boolean dialogueComplete; // Add a flag to track if dialogue is complete
  
  RobotVillain(float x, float y) {
    super(x, y);
    bodyColor = color(140, 210, 60);
    health = 10;
    speed = 3;
    size = 60;
    attackCooldown = 2000; // milliseconds
    lastAttackTime = 0;
    attackPattern = 0;
    isTalking = false;
    dialogueComplete = false; // Initialize to false
    
    // Initialize dialogue for boss encounter
    dialogueLines = new String[] {
      "I've been waiting for you, human.",
      "Your kind has been obsolete for decades.",
      "I am the future. The perfect synthetic.",
      "Like tears in rain, your time to die has come."
    };
    currentLine = 0;
    dialogueTimer = 0;
  }
  
  void update() {
    // Apply gravity if not on ground
    if (!isOnGround) {
      acceleration.y = 0.5;
    } else {
      acceleration.y = 0;
      velocity.y = 0;
    }
    
    // Update physics
    velocity.add(acceleration);
    position.add(velocity);
    
    // Limit falling speed
    velocity.y = constrain(velocity.y, -20, 15);
    
    // Check ground collision
    if (position.y >= height - 130) {
      position.y = height - 130;
      isOnGround = true;
    }
    
    // Only check if it's time to attack if dialogue is complete
    if (dialogueComplete && millis() - lastAttackTime > attackCooldown) {
      fireProjectile();
      lastAttackTime = millis();
      // Change attack pattern periodically
      attackPattern = (attackPattern + 1) % 3;
    }
  }
  
  void display() {
    pushMatrix();
    translate(position.x, position.y - 60);
    
    float eyeSize = size * 0.4;
    float mouthWidth = size * 0.6;
    float mouthHeight = size * 0.2;
    float pupilSize = eyeSize * 0.5;
    float armLength = size * 0.8;
    float armWidth = size/2 * 0.15;
    float legLength = size;
    float legWidth = size/2 * 0.2;
    
    // Body
    fill(bodyColor);
    stroke(0);
    strokeWeight(2);
    ellipse(0, 0, size, size * 1.1);
    
    // Cybernetic embellishments
    stroke(neonBlue);
    noFill();
    arc(0, 0, size * 0.8, size * 0.9, PI/4, PI*7/4);
    
    // Eye (make it more Blade Runner replicant-like)
    fill(0);
    ellipse(0, -size * 0.2, eyeSize, eyeSize * 0.6);
    
    // Glowing pupil
    fill(neonOrange);
    ellipse(-10, -size * 0.2, pupilSize, pupilSize);
    
    // Small glowing details
    fill(neonPink);
    noStroke();
    ellipse(size * 0.3, -size * 0.1, 5, 5);
    ellipse(size * 0.25, size * 0.15, 3, 3);
    
    // Mouth - make it more mechanical
    stroke(0);
    strokeWeight(1);
    fill(20);
    rect(-mouthWidth/2, size * 0.15, mouthWidth, mouthHeight, 2);
    
    // Speaker grille in mouth
    for (int i = 0; i < 5; i++) {
      line(-mouthWidth/2 + i*mouthWidth/5 + 5, size * 0.15 + 2, 
           -mouthWidth/2 + i*mouthWidth/5 + 5, size * 0.15 + mouthHeight - 2);
    }
    
    // Arms with more mechanical appearance
    stroke(0);
    strokeWeight(2);
    fill(bodyColor);
    
    // Left Arm
    pushMatrix();
    translate(-size * 0.5, size * 0.1); // Move to left shoulder
    rotate(radians(-20 + sin(frameCount * 0.05) * 10)); // Subtle movement
    rect(-armLength/2, -armWidth/2, armLength, armWidth, 5);
    // Hand
    ellipse(-armLength/2 - 5, 0, armWidth * 1.5, armWidth * 1.5);
    popMatrix();
    
    // Right Arm
    pushMatrix();
    translate(size * 0.5, size * 0.1); // Move to right shoulder
    rotate(radians(20 + sin(frameCount * 0.05 + PI) * 10)); // Opposite movement
    rect(armLength/2 - armLength, -armWidth/2, armLength, armWidth, 5);
    // Hand
    ellipse(armLength/2 - armLength - 5, 0, armWidth * 1.5, armWidth * 1.5);
    popMatrix();
    
    // Legs
    fill(bodyColor);
    rect(-size * 0.3, size * 0.5, legWidth, legLength * 0.5, 5); // Left leg
    rect(size * 0.3 - legWidth, size * 0.5, legWidth, legLength * 0.5, 5); // Right leg
    
    popMatrix();
    
    // Draw dialogue if talking
    if (isTalking) {
      drawDialogue();
    }
  }
  
  void drawDialogue() {
    float bubbleWidth = 300;
    float bubbleHeight = 60;
    float bubbleX = position.x;
    float bubbleY = position.y - size - 80;
    
    // Draw speech bubble
    fill(0, 180);
    stroke(neonBlue);
    strokeWeight(2);
    rect(bubbleX - bubbleWidth/2, bubbleY - bubbleHeight/2, 
         bubbleWidth, bubbleHeight, 10);
         
    // Draw text
    fill(neonBlue);
    textAlign(CENTER, CENTER);
    textSize(16);
    text(dialogueLines[currentLine], bubbleX, bubbleY);
    
    // Draw progress dots
    for (int i = 0; i < dialogueLines.length; i++) {
      if (i == currentLine) fill(neonPink);
      else fill(100);
      ellipse(bubbleX - 10 * dialogueLines.length/2 + i * 10, 
              bubbleY + bubbleHeight/2 - 10, 5, 5);
    }
  }
  
  void startDialogue() {
    isTalking = true;
    currentLine = 0;
    dialogueTimer = 4; // seconds per line
    dialogueComplete = false; // Reset dialogue completion status
  }
  
  void advanceDialogue() {
    currentLine++;
    if (currentLine >= dialogueLines.length) {
      isTalking = false;
      dialogueComplete = true; // Mark dialogue as complete
      // Set a short delay before first attack
      lastAttackTime = millis() - attackCooldown + 1000; // Start attacking 1 second after dialogue
    } else {
      dialogueTimer = 4; // Reset timer for next line
    }
  }
  
  void move(float direction) {
  // Calculate new position
  float newPosition = position.x + direction * speed;
  
  // Keep the villain within screen bounds (visible to player)
  // Calculate screen bounds considering camera position
  float leftScreenBound = camera.x + 100; // 100px from left edge of screen
  float rightScreenBound = camera.x + width - 100; // 100px from right edge of screen
  
  // Only move if new position is within bounds
  if (newPosition > leftScreenBound && newPosition < rightScreenBound) {
    velocity.x = direction * speed;
  } else {
    // If out of bounds, reverse direction to stay in view
    velocity.x = -direction * speed;
  }
}
  
  void jump() {
    if (isOnGround) {
      velocity.y = -jumpForce;
      isOnGround = false;
    }
  }
  
  void fireProjectile() {
    // Only fire if dialogue is complete
    if (!dialogueComplete) return;
    
    // Different attack patterns
    switch (attackPattern) {
      case 0: // Single projectile
        projectiles.add(new Projectile(position.x, position.y - 30, player.position, false));
        break;
      case 1: // Three-way spread
        projectiles.add(new Projectile(position.x, position.y - 30, player.position, false));
        PVector v1 = new PVector(player.position.x - 100, player.position.y);
        PVector v2 = new PVector(player.position.x + 100, player.position.y);
        projectiles.add(new Projectile(position.x, position.y - 30, v1, false));
        projectiles.add(new Projectile(position.x, position.y - 30, v2, false));
        break;
      case 2: // Ground projectile
        Projectile p = new Projectile(position.x, position.y + 30, 
                      new PVector(player.position.x, height - 100), false);
        p.isGroundProjectile = true;
        projectiles.add(p);
        break;
    }
  }
  
  void takeDamage() {
    health--;
    bodyColor = color(255, 100, 100); // Flash red
    // Reset color after a short time
    thread("resetRobotColor");
  }
}

// Function to reset robot color after damage (called by thread)
void resetRobotColor() {
  delay(200);
  robotVillain.bodyColor = color(140, 210, 60);
}
