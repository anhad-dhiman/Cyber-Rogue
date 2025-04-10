// Camera class to handle scrolling of the game world
class Camera {
  float x; // x position of camera
  float y; // y position of camera (if needed for vertical scrolling)
  float targetX; // the target x position (usually player's position)
  float easing = 0.05; // how smoothly the camera follows the target (0-1)
  float levelWidth; // total width of the level
  float screenWidth; // width of the screen
  float screenHeight; // height of the screen
  float leftBoundary; // left boundary for camera movement
  float rightBoundary; // right boundary for camera movement
  
  // Boss fight specific fields
  boolean inBossFight = false;
  float villainX = 0; // Track villain position
  
  Camera(float screenWidth, float screenHeight, float levelWidth) {
    this.x = 0;
    this.y = 0;
    this.targetX = 0;
    this.screenWidth = screenWidth;
    this.screenHeight = screenHeight;
    this.levelWidth = levelWidth;
    
    // Set camera movement boundaries
    // Camera only starts moving when player is in middle third of screen
    this.leftBoundary = screenWidth / 3;
    this.rightBoundary = screenWidth * 2/3;
  }
  
  // Update camera position based on target (usually the player)
  void update(float targetX) {
    this.targetX = targetX;
    
    if (inBossFight) {
      // In boss fight, keep both player and villain in frame
      updateBossFightCamera();
    } else {
      // Normal camera behavior for regular levels
      // Only move camera if target is beyond boundaries
      if (targetX - x > rightBoundary) {
        float targetCameraX = targetX - rightBoundary;
        x += (targetCameraX - x) * easing;
      } else if (targetX - x < leftBoundary) {
        float targetCameraX = targetX - leftBoundary;
        x += (targetCameraX - x) * easing;
      }
    }
    
    // Ensure camera doesn't go beyond level boundaries
    x = constrain(x, 0, levelWidth - screenWidth);
  }
  
  // Special camera update for boss fight to keep both characters in view
  void updateBossFightCamera() {
  // Calculate the midpoint between player and villain
  float midpoint = (targetX + villainX) / 2;
  
  // Determine a good camera position that shows both characters
  float idealCameraX = midpoint - screenWidth / 2;
  
  // Move camera smoothly toward this position
  x += (idealCameraX - x) * easing;
  
  // Make sure villain stays in frame
  float villainScreenX = villainX - x;
  if (villainScreenX > screenWidth - 150) {
    // Villain is getting too close to right edge
    x = villainX - screenWidth + 150;
  } else if (villainScreenX < 150) {
    // Villain is getting too close to left edge
    x = villainX - 150;
  }
  
  // Also ensure player stays in frame
  float playerScreenX = targetX - x;
  if (playerScreenX > screenWidth - 150) {
    // Player is getting too close to right edge
    x = targetX - screenWidth + 150;
  } else if (playerScreenX < 150) {
    // Player is getting too close to left edge
    x = targetX - 150;
  }
  
  // Ensure camera doesn't go beyond level boundaries
  x = constrain(x, 0, levelWidth - screenWidth);
}
  
  // Set boss fight mode
  void setBossFightMode(boolean enabled) {
    inBossFight = enabled;
  }
  
  // Update villain position for boss fight camera
  void setVillainPosition(float x) {
    villainX = x;
  }
  
  // Begin scene rendering with camera offset
  void begin() {
    pushMatrix();
    translate(-x, -y);
  }
  
  // End scene rendering
  void end() {
    popMatrix();
  }
  
  // Convert world coordinates to screen coordinates
  PVector worldToScreen(PVector worldPos) {
    return new PVector(worldPos.x - x, worldPos.y - y);
  }
  
  // Convert screen coordinates to world coordinates
  PVector screenToWorld(PVector screenPos) {
    return new PVector(screenPos.x + x, screenPos.y + y);
  }
  
  // Check if an object is visible in the camera's view
  boolean isVisible(GameObject obj) {
    return (obj.position.x + obj.size > x && 
            obj.position.x - obj.size < x + screenWidth);
  }
  
  boolean isVisible(Projectile obj) {
    return (obj.position.x + obj.size > x && 
            obj.position.x - obj.size < x + screenWidth);
  }
}
