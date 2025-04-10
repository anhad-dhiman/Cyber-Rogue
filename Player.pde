
// Player class
class Player extends Character {
  int score;
  boolean isHiding;
  PlayerState state;
  int invincibilityFrames;
  
  Player(float x, float y) {
    super(x, y);
    score = 0;
    isHiding = false;
    state = PlayerState.IDLE;
    invincibilityFrames = 0;
  }
  
  void update() {
    // Apply gravity
    if (!isOnGround) {
      acceleration.y = 0.8;
    } else {
      acceleration.y = 0;
      velocity.y = 0;
    }
    
    // Update physics
    velocity.add(acceleration);
    position.add(velocity);
    
    // Limit falling speed
    velocity.y = constrain(velocity.y, -20, 20);
    
    // Add visual feedback when successfully hiding from pursuers
  if (isHiding) {
    boolean wasBeingPursued = false;
    for (Drone drone : drones) {
      if (drone.state == DroneState.PURSUING && 
          PVector.dist(position, drone.position) < drone.detectionRadius * 1.5) {
        wasBeingPursued = true;
        break;
      }
    }
    
    if (wasBeingPursued) {
      // Show "hidden" indicator
      fill(0, 255, 0, 150);
      textAlign(CENTER);
      textSize(12);
      text("HIDDEN", position.x, position.y - 40);
    }
  }
    
    // Check ground collision
    if (position.y >= height - 130) {
      position.y = height - 130;
      isOnGround = true;
      
      // If player was jumping, return to IDLE or RUNNING
      if (state == PlayerState.JUMPING) {
        state = velocity.x != 0 ? PlayerState.RUNNING : PlayerState.IDLE;
      }
    }
    
    // Keep player within screen bounds
    position.x = constrain(position.x, 0, camera.levelWidth - size);
    
    // Update player state based on movement
    updateState();
    
    // Decrement invincibility frames
    if (invincibilityFrames > 0) {
      invincibilityFrames--;
    }
  }
  
  void updateState() {
    // Update state based on current conditions
    if (isHiding) {
      state = PlayerState.HIDING;
    } else if (!isOnGround) {
      state = PlayerState.JUMPING;
    } else if (abs(velocity.x) > 0.1) {
      state = PlayerState.RUNNING;
    } else {
      state = PlayerState.IDLE;
    }
  }
  
  void display() {
    // Flicker when invincible
    if (invincibilityFrames > 0 && frameCount % 5 > 2) {
      return;
    }
    
    // Draw player based on state
    switch (state) {
      case IDLE:
        drawIdlePlayer();
        break;
      case RUNNING:
        drawRunningPlayer();
        break;
      case JUMPING:
        drawJumpingPlayer();
        break;
      case HIDING:
        drawHidingPlayer();
        break;
      case DETECTED:
        drawDetectedPlayer();
        break;
    }
    
    // Draw state indicator (for debugging)
    fill(255);
    textSize(12);
    text(state.toString(), position.x, position.y - 30);
  }
  
  void drawIdlePlayer() {
    // Draw player body
    fill(neonBlue, 200);
    stroke(neonBlue);
    ellipse(position.x, position.y - 15, size, size);
    
    // Draw legs
    stroke(neonBlue);
    line(position.x, position.y - 5, position.x - 10, position.y + 15);
    line(position.x, position.y - 5, position.x + 10, position.y + 15);
    
    // Draw cyberpunk details
    fill(neonPink);
    noStroke();
    ellipse(position.x - 7, position.y - 15, 5, 5); // Eye
  }
  
  void drawRunningPlayer() {
    // Running animation - legs move
    float legOffset = sin(frameCount * 0.2) * 10;
    
    // Draw player body
    fill(neonBlue, 200);
    stroke(neonBlue);
    ellipse(position.x, position.y - 15, size, size);
    
    // Draw legs with movement
    stroke(neonBlue);
    line(position.x, position.y - 5, position.x - 10, position.y + 15 + legOffset);
    line(position.x, position.y - 5, position.x + 10, position.y + 15 - legOffset);
    
    // Draw cyberpunk details
    fill(neonPink);
    noStroke();
    ellipse(position.x - 7, position.y - 15, 5, 5); // Eye
  }
  
  void drawJumpingPlayer() {
    // Draw player body
    fill(neonBlue, 200);
    stroke(neonBlue);
    ellipse(position.x, position.y - 15, size, size);
    
    // Draw legs tucked up
    stroke(neonBlue);
    line(position.x, position.y - 5, position.x - 15, position.y);
    line(position.x, position.y - 5, position.x + 15, position.y);
    
    // Draw cyberpunk details
    fill(neonPink);
    noStroke();
    ellipse(position.x - 7, position.y - 15, 5, 5); // Eye
  }
  
  // Add a more visual hiding indicator
void drawHidingPlayer() {
  // Draw player hiding (crouched)
  fill(neonBlue, 60); // More transparent when hiding
  stroke(neonBlue, 60);
  ellipse(position.x, position.y, size, size * 0.5);
  
  // Draw hiding indicator
  noStroke();
  fill(neonBlue, 100 + 50 * sin(frameCount * 0.2));
  for (int i = 0; i < 3; i++) {
    ellipse(position.x, position.y - 25, 5 + i*2, 5 + i*2);
  }
}
  
  void drawDetectedPlayer() {
    // Draw player with alert indicator
    fill(neonOrange, 200);
    stroke(neonOrange);
    ellipse(position.x, position.y - 15, size, size);
    
    // Draw legs
    stroke(neonOrange);
    line(position.x, position.y - 5, position.x - 10, position.y + 15);
    line(position.x, position.y - 5, position.x + 10, position.y + 15);
    
    // Draw alert symbol
    fill(neonOrange);
    triangle(position.x, position.y - 40, position.x - 7, position.y - 55, position.x + 7, position.y - 55);
    fill(0);
    text("!", position.x, position.y - 45);
  }
  
  void move(float direction) {
    // Only move if not hiding
    if (!isHiding) {
      // Implementation of the abstract method from Character
      velocity.x = direction * speed;
      
      // Update state based on movement direction
      if (abs(direction) > 0.1) {
        state = PlayerState.RUNNING;
      } else if (isOnGround) {
        state = PlayerState.IDLE;
      }
    } else {
      // If hiding, don't allow movement
      velocity.x = 0;
    }
  }
  
void moveLeft() {
  move(-1); // Negative direction for left
}

void moveRight() {
  move(1); // Positive direction for right
}
  
  void stopMoving() {
    velocity.x = 0;
    if (isOnGround && !isHiding) {
      state = PlayerState.IDLE;
    }
  }
  
  void jump() {
    if (isOnGround) {
      velocity.y = -jumpForce;
      isOnGround = false;
      state = PlayerState.JUMPING;
    }
  }
  
  void crouch() {
    // Implement crouching behavior
    speed = 2; // Slower when crouching
  }
  
  void stopCrouching() {
    speed = 5; // Normal speed
  }
  
  void toggleHiding() {
    isHiding = !isHiding;
    
    if (isHiding) {
      // Stop movement when hiding
      velocity.x = 0;
      state = PlayerState.HIDING;
      // Make player harder to see when hiding
      size *= 0.7; // Make character smaller when hiding
    } else {
      state = isOnGround ? (abs(velocity.x) > 0.1 ? PlayerState.RUNNING : PlayerState.IDLE) : PlayerState.JUMPING;
      // Restore original size
      size = 30; // Reset to original size
    }
  }
  
  void takeDamage() {
    if (invincibilityFrames <= 0) {
      health--;
      invincibilityFrames = 60; // 1 second of invincibility
      state = PlayerState.DETECTED;
    }
  }
  
  void detectDrone() {
    state = PlayerState.DETECTED;
  }
}
