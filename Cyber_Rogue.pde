
// Global variables
PFont titleFont, menuFont;
PImage backgroundImg;
boolean[] levelLocked = {false, true}; // Level 1 unlocked, Level 2 locked initially
int gameState = 0; // 0 = menu, 1 = playing, 2 = game over
int selectedOption = 0;
float neonFlicker = 0;
color neonPink = color(255, 41, 117);
color neonBlue = color(0, 195, 255);
color neonOrange = color(255, 148, 54);

// Game object collections
ArrayList<GameObject> gameObjects = new ArrayList<GameObject>();
ArrayList<Drone> drones = new ArrayList<Drone>();
Player player;
Level currentLevel;
boolean levelCompleted = false;
ExitPoint exitPoint;
Camera camera;

// Setup function
void setup() {
  size(800, 600);
  // Load assets
  titleFont = createFont("Arial Bold", 48);
  menuFont = createFont("Arial", 24);
  // Create a placeholder background
  backgroundImg = createImage(width, height, RGB);
  createCyberpunkBackground();
  
  // Initialize level 1
  initializeLevel1();
  // Level width is twice the screen width
  camera = new Camera(width, height, width * 2);
}

void initializeLevel1() {
  // Clear any existing objects
  gameObjects.clear();
  drones.clear();
  
  // Create player character at the beginning of the level
  player = new Player(100, height - 150);
  gameObjects.add(player);
  
  // Create drones across the ENTIRE level width
  float levelWidth = width * 2; // Match with camera's levelWidth
  for (int i = 0; i < 10; i++) {
    // Scatter drones across the full level width (from 100 to levelWidth-100)
    float droneX = 100 + random(levelWidth - 200);
    Drone drone = new Drone(droneX, random(100, height-200), levelWidth);
    drones.add(drone);
    gameObjects.add(drone);
  }
  
  //// Create buildings across the full level width
  //for (int i = 0; i < 10; i++) { // More buildings for a longer level
  //  Building building = new Building(i * 200, height/2, random(100, 150), random(200, 400));
  //  gameObjects.add(building);
  //}
  
  // Create the current level
  currentLevel = new Level(1, "City Streets");
  
  // Create exit point at the end of the level
  exitPoint = new ExitPoint(width*2 - 30, height - 130);
  gameObjects.add(exitPoint);
  
  // Reset level completion flag
  levelCompleted = false;
}

// Modified createCyberpunkBackground to be tileable
void createCyberpunkBackground() {
  backgroundImg.loadPixels();
  for (int i = 0; i < backgroundImg.pixels.length; i++) {
    int x = i % width;
    int y = i / width;
    
    // Create dark cityscape silhouette at bottom
    float cityHeight = noise(x * 0.01) * 200;
    if (y > height - cityHeight) {
      backgroundImg.pixels[i] = color(10, 15, 30);
    } 
    // Create dark gradient sky
    else {
      float skyGradient = map(y, 0, height - cityHeight, 0, 1);
      backgroundImg.pixels[i] = color(
        lerp(5, 20, skyGradient),
        lerp(5, 25, skyGradient),
        lerp(40, 60, skyGradient)
      );
    }
    
    // Add some distant lights
    if (random(1) > 0.9995) {
      for (int j = 0; j < 10; j++) {
        int px = x + j - 5;
        int py = y + j - 5;
        if (px >= 0 && px < width && py >= 0 && py < height) {
          int idx = py * width + px;
          if (idx >= 0 && idx < backgroundImg.pixels.length) {
            backgroundImg.pixels[idx] = color(neonOrange, 150);
          }
        }
      }
    }
  }
  backgroundImg.updatePixels();
}

// Main draw loop
void draw() {
  // Update neon flicker effect
  neonFlicker = sin(frameCount * 0.1) * 0.2 + 0.8;
  
  if (gameState == 0) {
    drawMenu();
  } else if (gameState == 1) {
    drawGame();
  } else if (gameState == 2) {
    drawGameOver();
  } else if (gameState == 3) {
    drawLevelComplete();
  }
}

// Draw menu
void drawMenu() {
  // Draw background
  image(backgroundImg, 0, 0);
  
  // Add scanlines effect
  drawScanlines();
  
  // Draw title
  drawTitle();
  
  // Draw menu options
  drawMenuOptions();
  
  // Draw level status indicators
  drawLevelStatus();
}

// Draw game
void drawGame() {
  // Update camera to follow player
  camera.update(player.position.x);
  
  // Begin rendering with camera
  camera.begin();
  
  // Draw rain effect on the background (consider modifying for camera)
  drawRain();
  
  // Draw only visible game objects
  for (int i = 0; i < gameObjects.size(); i++) {
    GameObject obj = gameObjects.get(i);
    if (camera.isVisible(obj)) {
      obj.update();
      obj.display();
    }
  }
  
  // End camera rendering
  camera.end();
  
  // Draw HUD (not affected by camera)
  drawHUD();
  
  // Check for collisions
  checkCollisions();
  
  // Sort drones based on distance to player for priority targeting
  if (frameCount % 60 == 0) {
    sortDronesByDistanceToPlayer();
  }
}

// Draw game over screen
void drawGameOver() {
  // Draw background
  image(backgroundImg, 0, 0);
  
  // Add scanlines effect
  drawScanlines();
  
  // Draw game over text
  textFont(titleFont);
  textAlign(CENTER);
  fill(neonPink, 255 * neonFlicker);
  text("GAME OVER", width/2, height/2 - 50);
  
  textFont(menuFont);
  fill(neonBlue, 200 * neonFlicker);
  text("PRESS ENTER TO RETRY", width/2, height/2 + 30);
}

// Draw rain effect
void drawRain() {
  background(10, 15, 30); // Dark background
  
  // Draw background buildings
  for (GameObject obj : gameObjects) {
    if (obj instanceof Building) {
      obj.display();
    }
  }
  
  // Draw rain - adjust for camera position
  stroke(neonBlue, 100);
  for (int i = 0; i < 100; i++) {
    float x = random(camera.x, camera.x + width);
    float y = random(height);
    line(x, y, x - 2, y + 10);
  }
  
  // Draw puddles - adjust for camera position
  noStroke();
  fill(neonBlue, 20);
  for (int i = 0; i < 10; i++) {
    ellipse(random(camera.x, camera.x + width), height - 10, random(50, 100), 5);
  }
  
  // Draw street
  fill(20);
  rect(camera.x, height - 100, width * 2, 100); // Extend street to cover level width
  
  // Draw street lines - adjust for camera position
  stroke(255, 150);
  strokeWeight(2);
  for (int i = 0; i < width * 2; i += 50) {
    if (i >= camera.x - 50 && i <= camera.x + width + 50) {
      line(i, height - 50, i + 30, height - 50);
    }
  }
  strokeWeight(1);
}

// Draw HUD (Heads-Up Display)
void drawHUD() {
  textFont(menuFont);
  textAlign(LEFT);
  fill(neonPink);
  text("LEVEL: " + currentLevel.levelNumber, 20, 30);
  text("SCORE: " + player.score, 20, 60);
  
  // Draw player health
  fill(neonBlue);
  text("HEALTH: ", 20, 90);
  for (int i = 0; i < player.health; i++) {
    fill(neonBlue, 200 * neonFlicker);
    rect(100 + i * 30, 75, 20, 20);
  }
}

// Draw scanlines for retro effect
void drawScanlines() {
  for (int y = 0; y < height; y += 4) {
    stroke(0, 30);
    line(0, y, width, y);
  }
}

// Draw game title
void drawTitle() {
  textFont(titleFont);
  textAlign(CENTER);
  
  // Shadow
  fill(#0f0f0f);
  text("Cyber Rogue", width/2 + 5, 120 + 5);
  
  // Main title with flicker
  fill(neonBlue, 255 * neonFlicker);
  text("Cyber Rogue", width/2, 120);
  
  // Subtitle
  textFont(menuFont);
  fill(neonPink, 200 * neonFlicker);
  text("A BLADE RUNNER INSPIRED GAME", width/2, 165);
}

// Draw menu options
void drawMenuOptions() {
  textFont(menuFont);
  textAlign(CENTER);
  
  String[] options = {"LEVEL 1: CITY STREETS", "LEVEL 2: CORPORATE TOWER", "EXIT"};
  
  for (int i = 0; i < options.length; i++) {
    float y = height/2 + i * 60;
    
    // Locked level effect
    if (i == 1 && levelLocked[1]) {
      fill(100, 150);
      text(options[i] + " [LOCKED]", width/2, y);
      continue;
    }
    
    // Selected option
    if (i == selectedOption) {
      // Draw selection box
      noFill();
      stroke(neonPink, 200 * neonFlicker);
      rect(width/2 - 200, y - 30, 400, 40, 5);
      
      // Draw text with flicker effect
      fill(neonPink, 255 * neonFlicker);
      text(options[i], width/2, y);
      
      // Draw selection arrows
      text(">", width/2 - 220, y);
      text("<", width/2 + 220, y);
    } 
    else {
      // Unselected option
      fill(200, 180);
      text(options[i], width/2, y);
    }
  }
}

// Draw level status indicators
void drawLevelStatus() {
  textAlign(LEFT);
  textSize(16);
  
  fill(200);
  text("NAVIGATION: ARROW KEYS", 20, height - 60);
  text("SELECT: ENTER", 20, height - 30);
  
  // Draw version number in corner
  textAlign(RIGHT);
  fill(100);
  text("v0.1", width - 20, height - 20);
}

// Handle keyboard input
void keyPressed() {
  if (gameState == 0) {
    // Menu controls
    if (keyCode == UP) {
      selectedOption = (selectedOption - 1 + 3) % 3;
    } else if (keyCode == DOWN) {
      selectedOption = (selectedOption + 1) % 3;
    } else if (keyCode == ENTER || keyCode == RETURN) {
      handleMenuSelection();
    }
  } else if (gameState == 1) {
    // Game controls
    if (keyCode == LEFT) {
      player.moveLeft();
    } else if (keyCode == RIGHT) {
      player.moveRight();
    } else if (keyCode == UP) {
      player.jump();
    } else if (keyCode == DOWN) {
      player.crouch();
    } else if (key == 'h' || key == 'H') {
      player.toggleHiding();
    }
  } else if (gameState == 2) {
    // Game over controls
    if (keyCode == ENTER || keyCode == RETURN) {
      resetGame();
    }
  } else if (gameState == 3) {
    if (keyCode == ENTER || keyCode == RETURN) {
      gameState = 0; // Return to menu
      selectedOption = 0;
    }
  }
}

void keyReleased() {
  if (gameState == 1) {
    // Stop movement when keys are released
    if (keyCode == LEFT || keyCode == RIGHT) {
      player.stopMoving();
    }
    if (keyCode == DOWN) {
      player.stopCrouching();
    }
  }
}

// Handle menu selection
void handleMenuSelection() {
  switch (selectedOption) {
    case 0:
      // Start Level 1
      startLevel(1);
      break;
    case 1:
      // Try to start Level 2 if unlocked
      if (!levelLocked[1]) {
        startLevel(2);
      }
      break;
    case 2:
      // Exit game
      exit();
      break;
  }
}

// Start the selected level
void startLevel(int level) {
  gameState = 1; // Set to playing
  
  if (level == 1) {
    initializeLevel1();
  } else if (level == 2) {
    // Initialize level 2 (to be implemented)
  }
}

// Reset game
void resetGame() {
  gameState = 0; // Back to menu
  selectedOption = 0;
}

// Check for collisions between player and drones
void checkCollisions() {
  for (Drone drone : drones) {
    if (drone.state == DroneState.PURSUING && collision(player, drone)) {
      player.takeDamage();
      if (player.health <= 0) {
        gameState = 2; // Game over
      }
    }
  }
  // Check if player reached the exit point
  if (collision(player, exitPoint) && !levelCompleted) {
    levelCompleted = true;
    completeLevel();
  }
}

void completeLevel() {
  // Calculate final score
  int timeBonus = max(0, 3000 - frameCount);
  player.score += timeBonus;
  
  // Play completion animation
  // (Will be triggered in the draw function)
  
  // Unlock next level if this is level 1
  if (currentLevel.levelNumber == 1) {
    levelLocked[1] = false;
  }
  
  // Show level complete screen for a few seconds, then return to menu
  gameState = 3; // New state for level complete
}

// Simple collision check
boolean collision(GameObject obj1, GameObject obj2) {
  return (abs(obj1.position.x - obj2.position.x) < 30 && 
          abs(obj1.position.y - obj2.position.y) < 30);
}

// Function to show the level complete screen
void drawLevelComplete() {
  // Draw background
  image(backgroundImg, 0, 0);
  
  // Add scanlines effect
  drawScanlines();
  
  // Draw level complete text
  textFont(titleFont);
  textAlign(CENTER);
  fill(neonBlue, 255 * neonFlicker);
  text("LEVEL COMPLETE", width/2, height/2 - 80);
  
  textFont(menuFont);
  fill(neonPink, 200 * neonFlicker);
  text("FINAL SCORE: " + player.score, width/2, height/2 - 20);
  
  if (currentLevel.levelNumber == 1) {
    fill(neonOrange, 200 * neonFlicker);
    text("LEVEL 2 UNLOCKED", width/2, height/2 + 40);
  }
  
  fill(neonBlue, 150 + 50 * sin(frameCount * 0.1));
  text("PRESS ENTER TO CONTINUE", width/2, height/2 + 100);
  
  // After a few seconds, allow the player to press Enter to continue
  if (frameCount % 180 < 90) {
    fill(255);
    text("→", width/2 + 160, height/2 + 100);
  }
}

// Sort drones by distance to player using QuickSort
void sortDronesByDistanceToPlayer() {
  if (drones.size() <= 1) return;
  
  quickSortDrones(0, drones.size() - 1);
  
  // After sorting, adjust drone priorities
  for (int i = 0; i < drones.size(); i++) {
    Drone drone = drones.get(i);
    // Closest drones are more aggressive
    if (i < 2) {
      drone.aggressionLevel = 2; // High aggression
    } else {
      drone.aggressionLevel = 1; // Normal aggression
    }
  }
}

// QuickSort implementation for drones
void quickSortDrones(int low, int high) {
  if (low < high) {
    int pivotIndex = partition(low, high);
    quickSortDrones(low, pivotIndex - 1);
    quickSortDrones(pivotIndex + 1, high);
  }
}

int partition(int low, int high) {
  Drone pivot = drones.get(high);
  float pivotDistance = PVector.dist(pivot.position, player.position);
  int i = low - 1;
  
  for (int j = low; j < high; j++) {
    Drone current = drones.get(j);
    float currentDistance = PVector.dist(current.position, player.position);
    
    if (currentDistance < pivotDistance) {
      i++;
      // Swap drones
      Drone temp = drones.get(i);
      drones.set(i, drones.get(j));
      drones.set(j, temp);
    }
  }
  
  // Swap pivot to its final position
  Drone temp = drones.get(i + 1);
  drones.set(i + 1, drones.get(high));
  drones.set(high, temp);
  
  return i + 1;
}

// A* search algorithm implementation for drone pathfinding
PVector findPathToPlayer(PVector start, PVector target) {
  PVector direction = PVector.sub(target, start);
  direction.normalize();
  return direction;
}
