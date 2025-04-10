// Drone class
class Drone extends GameObject {
  DroneState state;
  float detectionRadius;
  float patrolSpeed;
  int aggressionLevel;
  PVector patrolPoint;
  PVector targetPoint;
  float levelWidth;
  float screenWidth;  // Store screen width as a fallback
  float screenHeight; // Store screen height as a fallback
  
  // Updated Drone constructor
  Drone(float x, float y, float levelWidth) {
    super(x, y);
    state = DroneState.PATROLLING;
    detectionRadius = 0;
    patrolSpeed = 2;
    aggressionLevel = 1;
    this.levelWidth = levelWidth;
    
    // Store screen dimensions as fallback
    this.screenWidth = width;  // Processing's built-in width
    this.screenHeight = height; // Processing's built-in height
    
    // Set initial patrol point
    patrolPoint = new PVector(random(width), random(height/2));
    targetPoint = patrolPoint.copy();
  }
  
  // Get visible left edge (camera x position or 0 if camera is null)
  float getVisibleLeftEdge() {
    return (camera != null) ? camera.x : 0;
  }
  
  // Get visible right edge
  float getVisibleRightEdge() {
    if (camera != null) {
      return camera.x + camera.screenWidth;
    } else {
      return screenWidth; // Fall back to stored screen width
    }
  }
  
  // Reset patrol point to be within visible screen bounds
  void resetPatrolPoint() {
    // Calculate visible screen boundaries in world coordinates
    float visibleLeftEdge = getVisibleLeftEdge();
    float visibleRightEdge = getVisibleRightEdge();
    
    // Set new patrol point within visible area (with margin)
    float margin = 50; // Keep some distance from the edges
    patrolPoint = new PVector(
      random(visibleLeftEdge + margin, visibleRightEdge - margin),
      random(100, (camera != null ? camera.screenHeight : screenHeight) - 100)
    );
    
    targetPoint = patrolPoint.copy();
  }
  
  void update() {
    // First check if drone is off-screen and needs repositioning
    ensureVisibility();
    
    // Update drone behavior based on state
    switch (state) {
      case PATROLLING:
        patrol();
        break;
      case SEARCHING:
        search();
        break;
      case PURSUING:
        pursue();
        break;
      case RETURNING:
        returnToPatrol();
        break;
    }
    
    // Check if player is detected
    checkForPlayer();
    
    // Update position
    position.add(velocity);
    
    // Keep drone within level bounds
    position.x = constrain(position.x, 0, levelWidth - size);
    position.y = constrain(position.y, 0, (camera != null ? camera.screenHeight : screenHeight) - size);
  }
  
  // New method to ensure drone stays visible
  void ensureVisibility() {
    // Calculate visible screen boundaries in world coordinates
    float visibleLeftEdge = getVisibleLeftEdge();
    float visibleRightEdge = getVisibleRightEdge();
    float margin = 20; // Buffer to prevent drones from being partially off-screen
    
    // If drone is outside or about to go outside visible area, reposition it
    if (position.x < visibleLeftEdge + margin || position.x > visibleRightEdge - margin) {
      // Reset position to be within visible area
      position.x = constrain(position.x, visibleLeftEdge + margin, visibleRightEdge - margin);
      
      // Reset patrol point as well
      resetPatrolPoint();
      
      // If pursuing player, continue pursuit only if player is visible
      if (state == DroneState.PURSUING) {
        // Check if player is visible
        if (player != null) {
          if (player.position.x < visibleLeftEdge || player.position.x > visibleRightEdge) {
            state = DroneState.PATROLLING;
          }
        } else {
          // If player reference is null, revert to patrolling
          state = DroneState.PATROLLING;
        }
      }
    }
    
    // Also ensure patrol points are within visible area
    if (patrolPoint.x < visibleLeftEdge + margin || patrolPoint.x > visibleRightEdge - margin) {
      resetPatrolPoint();
    }
  }
  
  void patrol() {
    // Move toward patrol point
    PVector direction = PVector.sub(patrolPoint, position);
    
    // If reached patrol point, set a new one within visible screen
    if (direction.mag() < 10) {
      resetPatrolPoint();
      return;
    }
    
    // Add small random variations to make movement less predictable
    direction.normalize();
    direction.mult(patrolSpeed);
    direction.x += random(-0.3, 0.3);
    direction.y += random(-0.2, 0.2);
    velocity = direction;
  }
    
  void search() {
    // Search behavior - move in circular pattern
    float angle = frameCount * 0.05;
    
    velocity.x = cos(angle) * 2;
    velocity.y = sin(angle) * 2;
    
    // After searching for a while, return to patrol
    if (frameCount % 180 == 0) {
      state = DroneState.RETURNING;
    }
    
    // Check if search is taking drone off-screen
    float visibleLeftEdge = getVisibleLeftEdge();
    float visibleRightEdge = getVisibleRightEdge();
    float margin = 30;
    
    if (position.x < visibleLeftEdge + margin || position.x > visibleRightEdge - margin) {
      // Reverse horizontal direction to head back on screen
      velocity.x = -velocity.x;
    }
  }
  
  void pursue() {
    // Check if player reference is valid
    if (player == null) {
      state = DroneState.PATROLLING;
      return;
    }
    
    // Check if player is hiding - if so, switch to searching state
    if (player.isHiding) {
      state = DroneState.SEARCHING;
      targetPoint = player.position.copy(); // Last known position
      return;
    }
    
    // Check if player is offscreen - if so, return to patrolling
    float visibleLeftEdge = getVisibleLeftEdge();
    float visibleRightEdge = getVisibleRightEdge();
    
    if (player.position.x < visibleLeftEdge || player.position.x > visibleRightEdge) {
      state = DroneState.PATROLLING;
      resetPatrolPoint();
      return;
    }
    
    // Use A* algorithm to find path to player
    PVector direction = findPathToPlayer(position, player.position);
    direction.mult(patrolSpeed * 1.5 * aggressionLevel); // Move faster when pursuing
    velocity = direction;
    
    // If lost sight of player, start searching
    if (PVector.dist(position, player.position) > detectionRadius * 1.5) {
      state = DroneState.SEARCHING;
      targetPoint = player.position.copy(); // Last known position
    }
  }
  
  void returnToPatrol() {
    // Return to patrol route
    PVector direction = PVector.sub(patrolPoint, position);
    
    // If reached patrol point or patrol point is off screen, reset it
    if (direction.mag() < 10 || !isPatrolPointVisible()) {
      resetPatrolPoint();
      state = DroneState.PATROLLING;
      return;
    }
    
    // Move toward patrol point
    direction.normalize();
    direction.mult(patrolSpeed);
    velocity = direction;
  }
  
  // Check if patrol point is within visible screen area
  boolean isPatrolPointVisible() {
    float visibleLeftEdge = getVisibleLeftEdge();
    float visibleRightEdge = getVisibleRightEdge();
    float margin = 50;
    
    return (patrolPoint.x >= visibleLeftEdge + margin && 
            patrolPoint.x <= visibleRightEdge - margin);
  }
  
  void checkForPlayer() {
    // Skip if player reference is null
    if (player == null) return;
    
    float distance = PVector.dist(position, player.position);
    
    // Check if player is in detection radius
    if (distance < detectionRadius) {
      // Only detect player if they're not hiding
      if (!player.isHiding) {
        state = DroneState.PURSUING;
        player.detectDrone();
      }
    }
  }
  
  void display() {
    // Draw drone body
    stroke(neonPink);
    fill(40, 40, 60);
    ellipse(position.x, position.y, size, size/2);
    
    // Draw propellers
    float propellerSpeed = frameCount * 0.5;
    stroke(neonPink, 150);
    line(position.x - 15, position.y, position.x - 25 + sin(propellerSpeed) * 5, position.y);
    line(position.x + 15, position.y, position.x + 25 + sin(propellerSpeed + PI) * 5, position.y);
    
    // Draw detection radius (when debugging)
    noFill();
    stroke(255, 0, 0, 50);
    ellipse(position.x, position.y, detectionRadius * 2, detectionRadius * 2);
    
    // Draw state indicator (for debugging)
    fill(255);
    textSize(10);
    text(state.toString(), position.x, position.y - 20);
    
    // Draw different lights based on state
    switch (state) {
      case PATROLLING:
        fill(0, 255, 0); // Green light  
        break;
      case SEARCHING:
        fill(255, 255, 0); // Yellow light
        break;
      case PURSUING:
        fill(255, 0, 0); // Red light
        break;
      case RETURNING:
        fill(0, 0, 255); // Blue light
        break;
    }
    
    ellipse(position.x, position.y, 10, 10);
  }
}
