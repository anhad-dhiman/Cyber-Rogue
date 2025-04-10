import processing.sound.*;


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
ArrayList<Projectile> projectiles = new ArrayList<Projectile>();
Player player;
Platform platform;
RobotVillain robotVillain;
Level currentLevel;
boolean levelCompleted = false;
ExitPoint exitPoint;
Camera camera;
DialogueSystem dialogueSystem;

SoundFile backgroundMusic;
boolean musicInitialized = false;
float musicVolume = 0.5;

// Setup function
void setup() {
  size(800, 600);
  // Load assets
  titleFont = createFont("Arial Bold", 48);
  menuFont = createFont("Arial", 24);
  // Create a placeholder background
  backgroundImg = createImage(width, height, RGB);
  createCyberpunkBackground();
  
  // Initialize background music
  initializeMusic();
  
  // Initialize level 1
  initializeLevel1();
  // Level width is twice the screen width
  camera = new Camera(width, height, width * 2);
}

void initializeMusic() {
  if (!musicInitialized) {
    try {
      // Load background music file
      backgroundMusic = new SoundFile(this, "447_The_Murky_Depths.mp3");
      
      // Set volume and loop continuously
      backgroundMusic.amp(musicVolume);
      backgroundMusic.loop();
      
      musicInitialized = true;
      println("Background music started successfully");
    } catch (Exception e) {
      println("Error loading background music: " + e.getMessage());
    }
  }
}

// Add this method to update music volume based on game state
void updateMusic() {
  if (musicInitialized) {
    if (gameState == 0) {
      // Menu volume - normal
      backgroundMusic.amp(musicVolume);
    } else if (gameState == 1) {
      // Gameplay volume - normal
      backgroundMusic.amp(musicVolume);
    } else if (gameState == 2) {
      // Game over - slightly lower
      backgroundMusic.amp(musicVolume * 0.8);
    } else if (gameState == 3) {
      // Level complete - slightly lower
      backgroundMusic.amp(musicVolume * 0.8);
    }
  }
}

// To stop the music when the game is closed
void stop() {
  if (musicInitialized) {
    backgroundMusic.stop();
  }
  super.stop();
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

// Level 2 - Boss Fight
void initializeLevel2() {
  // Clear any existing objects
  gameObjects.clear();
  drones.clear();
  projectiles.clear();
  
  // Create cyberpunk player character
  player = new CyberpunkPlayer(100, height - 150);
  gameObjects.add(player);
  
  // Create robot villain - position closer to the player for better visibility
  // Set a fixed position relative to screen width instead of using level width multiplier
  robotVillain = new RobotVillain(width - 200, height - 150);
  gameObjects.add(robotVillain);
  
  // Create the level
  currentLevel = new Level(2, "Corporate Tower");
  
  // Create platforms for a more interesting fight arena
  for (int i = 0; i < 5; i++) {
    float platformWidth = random(100, 200);
    float platformHeight = 20;
    float platformX = 200 + i * 300 + random(-50, 50);
    float platformY = height - 200 - i * 70 + random(-20, 20);
    
    Platform platform = new Platform(platformX, platformY, platformWidth, platformHeight);
    gameObjects.add(platform);
  }
  
  // Reset level completion flag
  levelCompleted = false;
  
  // Initialize projectiles list if not already created
  if (projectiles == null) {
    projectiles = new ArrayList<Projectile>();
  }
  
  // Configure camera for boss fight - set boss fight mode
  camera = new Camera(width, height, width * 2);
  camera.setBossFightMode(true);
  camera.setVillainPosition(robotVillain.position.x);
  
  // Initialize dialogue system
  dialogueSystem = new DialogueSystem();
  dialogueSystem.setupBossFightDialogue();
  
  // Set both characters to not take damage during dialogue
  player.invincibilityFrames = 9999; // Very high number to prevent damage during dialogue
  robotVillain.dialogueComplete = false;
}

// Function to start player dialogue after villain completes
void startPlayerDialogueAfterDelay() {
  // Wait until villain dialogue is complete
  while (robotVillain.isTalking) {
    delay(100); // Check every 100ms
  }
  
  // Add a small pause between villain and player dialogue
  delay(1000);
  
  // Start player dialogue
  ((CyberpunkPlayer)player).startDialogue();
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
  
    // Update background music
  updateMusic();
  
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
  
 void drawGame() {
  // In boss fight, update camera to track both player and villain
  if (currentLevel.levelNumber == 2 && robotVillain != null) {
    // Update villain position in the camera
    camera.setVillainPosition(robotVillain.position.x);
    
    // Constrain villain position to stay on screen
    float leftBound = camera.x + 100;
    float rightBound = camera.x + width - 100;
    if (robotVillain.position.x < leftBound) {
      robotVillain.position.x = leftBound;
      robotVillain.velocity.x = 0;
    } else if (robotVillain.position.x > rightBound) {
      robotVillain.position.x = rightBound;
      robotVillain.velocity.x = 0;
    }
  }
  
  // Update camera to follow player
  camera.update(player.position.x);
  
  // Begin rendering with camera
  camera.begin();
  
  // Draw background with cyberpunk elements
  drawCyberpunkBackground();
  
  // Draw rain effect
  drawRain();
  
  // Draw platforms first (background elements)
  for (GameObject obj : gameObjects) {
    if (obj instanceof Platform && camera.isVisible(obj)) {
      obj.display();
    }
  }
  
  // Draw characters and other objects
  for (GameObject obj : gameObjects) {
    if (!(obj instanceof Platform) && camera.isVisible(obj)) {
      obj.update();
      obj.display();
    }
  }
  
  // Draw projectiles
  for (Projectile p : projectiles) {
    if (camera.isVisible(p)) {
      p.display();
    }
  }
  
  // End camera rendering
  camera.end();
  
  // Draw HUD (not affected by camera)
  drawHUD();
  
  // Check for collisions
  checkCollisions();
  
  // If in level 2, handle dialogue and boss behavior
  if (currentLevel.levelNumber == 2) {
    // Make sure dialogueSystem is initialized
    if (dialogueSystem == null) {
      dialogueSystem = new DialogueSystem();
      dialogueSystem.setupBossFightDialogue();
    }
    
    // Update dialogue system
    dialogueSystem.update();
    
    // Draw dialogue bubbles
    dialogueSystem.draw();
    
    // Check if dialogue is complete and gameplay should start
    if (dialogueSystem.dialogueComplete && player.invincibilityFrames > 1000) {
      // Dialogue just completed - start boss fight
      player.invincibilityFrames = 60; // Give player a short grace period
      
      // Make sure villain is ready to fight
      if (robotVillain != null) {
        robotVillain.dialogueComplete = true; // Allow villain to attack
        
        // Ensure villain is visible to player
        float idealX = player.position.x + width/2 - 100;
        if (abs(robotVillain.position.x - idealX) > 300) {
          robotVillain.position.x = idealX;
        }
      }
      
      // Show fight start indicator
      fill(neonOrange, 200);
      textAlign(CENTER);
      textSize(32);
      text("FIGHT!", width/2, height/2);
    }
    
    // Only have the boss move if dialogue is complete
    if (dialogueSystem.dialogueComplete && frameCount % 120 == 0 && robotVillain != null) {
      // Move towards player sometimes, away other times
      float direction = random(1) > 0.7 ? 
        (robotVillain.position.x > player.position.x ? -1 : 1) : 
        (robotVillain.position.x > player.position.x ? 1 : -1);
      
      // Ensure villain doesn't move too far away from player
      float distanceToPlayer = abs(robotVillain.position.x - player.position.x);
      if (distanceToPlayer > width * 0.6) {
        // If too far, always move toward player
        direction = (robotVillain.position.x > player.position.x) ? -1 : 1;
      }
      
      robotVillain.move(direction);
      
      // Maybe jump
      if (random(1) > 0.7) {
        robotVillain.jump();
      }
    }
    
    // Show combat instructions after dialogue
    if (dialogueSystem.dialogueComplete && frameCount % 300 < 150) {
      textAlign(CENTER);
      fill(neonBlue, 150 + 50 * sin(frameCount * 0.1));
      textSize(16);
      text("PRESS SPACE TO FIRE", width/2, height - 30);
    }
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
  
  // For level 2, show boss health
  if (currentLevel.levelNumber == 2) {
    fill(neonOrange);
    textAlign(RIGHT);
    text("BOSS: ", width - 250, 30);
    
    // Boss health bar
    for (int i = 0; i < robotVillain.health; i++) {
      fill(neonOrange, 200 * neonFlicker);
      rect(width - 240 + i * 20, 15, 15, 15);
    }
    
    // Attack instruction reminder
    if (frameCount % 300 < 150 && !robotVillain.isTalking) {
      textAlign(CENTER);
      fill(neonBlue, 150 + 50 * sin(frameCount * 0.1));
      text("PRESS SPACE TO FIRE", width/2, height - 30);
    }
  }
}

// Draw scanlines for retro effect
void drawScanlines() {
  noStroke();
  fill(0, 20);
  for (int y = 0; y < height; y += 4) {
    rect(0, y, width, 2);
  }
  
  // CRT flicker effect
  if (random(100) > 98) {
    fill(255, 10);
    rect(0, 0, width, height);
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
    // Menu controls - keep arrow keys for menu navigation
    if (keyCode == UP) {
      selectedOption = (selectedOption - 1 + 3) % 3;
    } else if (keyCode == DOWN) {
      selectedOption = (selectedOption + 1) % 3;
    } else if (keyCode == ENTER || keyCode == RETURN) {
      handleMenuSelection();
    }
  } else if (gameState == 1) {
    // Check if in boss dialogue for level 2
    boolean inDialogue = false;
    if (currentLevel.levelNumber == 2 && dialogueSystem != null) {
      inDialogue = !dialogueSystem.dialogueComplete;
      
      // Allow skipping/advancing dialogue with ENTER
      if (inDialogue && (keyCode == ENTER || keyCode == RETURN)) {
        dialogueSystem.advanceDialogue();
        return;
      }
    }
    
    // Game controls - restrict movement during dialogue
    if (!inDialogue) {
      // WASD movement controls
      if (key == 'a' || key == 'A') {
        player.moveLeft();
      } else if (key == 'd' || key == 'D') {
        player.moveRight();
      } else if (key == 'w' || key == 'W') {
        player.jump();
      } else if (key == 's' || key == 'S') {
        player.toggleHiding(); // S is now for hiding/stealth
      } 
    }
    
    // Debug key to skip dialogue
    if (key == '`' && currentLevel.levelNumber == 2 && dialogueSystem != null) {
      dialogueSystem.skipDialogue();
      player.invincibilityFrames = 60;
      robotVillain.dialogueComplete = true;
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
    if (key == 'a' || key == 'A' || key == 'd' || key == 'D') {
      player.stopMoving();
    }
  }
}

// Add mouse handling for shooting
void mousePressed() {
  // Handle shooting with left mouse button
  if (mouseButton == LEFT && gameState == 1) {
    // Only in level 2 and if player is CyberpunkPlayer
    if (currentLevel.levelNumber == 2 && player instanceof CyberpunkPlayer) {
      ((CyberpunkPlayer)player).fireProjectile();
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
      initializeLevel2();
    }
  }

// Reset game
void resetGame() {
  gameState = 0; // Back to menu
  selectedOption = 0;
}

  // Check for collisions between player and drones
  void checkCollisions() {
    // Check if this is level 2 (boss fight)
    if (currentLevel.levelNumber == 2) {
      checkBossFightCollisions();
      return;
    }
    
    // Original code for level 1
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
  
  
// Boss fight collision handling
void checkBossFightCollisions() {
  // Check platform collisions for player
  checkPlatformCollisions(player);
  
  // Check platform collisions for robot villain
  checkPlatformCollisions(robotVillain);
  
  // First update all projectiles regardless of dialogue state
  for (int i = projectiles.size() - 1; i >= 0; i--) {
    Projectile p = projectiles.get(i);
    p.update();
    p.display();
    
    // Remove projectiles that have gone offscreen or expired
    if (p.position.x < 0 || p.position.x > width * 2 || 
        p.position.y < 0 || p.position.y > height ||
        p.isDead()) {
      projectiles.remove(i);
      continue;
    }
  }
  
  // Don't process damage collisions during dialogue
  if (dialogueSystem == null || !dialogueSystem.dialogueComplete) {
    return;
  }
  
  // Process collisions once dialogue is complete
  for (int i = projectiles.size() - 1; i >= 0; i--) {
    Projectile p = projectiles.get(i);
    
    // Check if projectile hit the player
    if (!p.isPlayerProjectile && 
        abs(p.position.x - player.position.x) < 20 && 
        abs(p.position.y - player.position.y) < 30 &&
        player.invincibilityFrames <= 0) {
      player.takeDamage();
      projectiles.remove(i);
      
      if (player.health <= 0) {
        gameState = 2; // Game over
      }
      continue;
    }
    
    // Check if projectile hit the villain
    if (p.isPlayerProjectile && 
        abs(p.position.x - robotVillain.position.x) < 30 && 
        abs(p.position.y - robotVillain.position.y) < 40) {
      robotVillain.takeDamage();
      projectiles.remove(i);
      
      if (robotVillain.health <= 0) {
        // Boss defeated!
        levelCompleted = true;
        completeLevel();
      }
      continue;
    }
  }
  
  // Check direct collision between player and robot villain
  // (Only when not in dialogue and invincibility frames are over)
  if (collision(player, robotVillain) && player.invincibilityFrames <= 0) {
    player.takeDamage();
  }
}
    // Platform collision detection
  void checkPlatformCollisions(Character character) {
    // Reset ground status
    character.isOnGround = false;
    
    // Check if character is on the main ground
    if (character.position.y >= height - 130) {
      character.position.y = height - 130;
      character.isOnGround = true;
      
      // If player was jumping, update state
      if (character == player && ((Player)character).state == PlayerState.JUMPING) {
        ((Player)character).state = character.velocity.x != 0 ? PlayerState.RUNNING : PlayerState.IDLE;
      }
    }
    
    // Check platforms
    for (GameObject obj : gameObjects) {
      if (obj instanceof Platform) {
        Platform platform = (Platform) obj;
        
        // Check if character is on top of platform
        if (character.velocity.y >= 0 && // Moving downward or stationary
            character.position.y >= platform.position.y - 30 && 
            character.position.y <= platform.position.y &&
            character.position.x >= platform.position.x - 15 &&
            character.position.x <= platform.position.x + platform.w + 15) {
          
          character.position.y = platform.position.y - 30;
          character.velocity.y = 0;
          character.isOnGround = true;
          
          // Update player state if landing on platform
          if (character == player && ((Player)character).state == PlayerState.JUMPING) {
            ((Player)character).state = character.velocity.x != 0 ? PlayerState.RUNNING : PlayerState.IDLE;
          }
        }
      }
    }
  }
  
  // Enhanced cyberpunk background for boss level
  void drawCyberpunkBackground() {
    if (currentLevel.levelNumber == 2) {
      // Corporate tower background for level 2
      background(5, 10, 25); // Dark background
      
      // Draw distant cityscape
      drawDistantCityscape();
      
      // Draw large corporate tower
      drawCorporateTower();
    } else {
      // Original background for level 1
      background(10, 15, 30);
      image(backgroundImg, camera.x, 0);
    }
  }
  
  // Draw distant cityscape for level 2
void drawDistantCityscape() {
  noStroke();
  
  // Parallax scrolling - cityscape moves slower than camera
  float parallaxOffset = camera.x * 0.2;
  
  // Distant buildings
  for (int i = 0; i < 20; i++) {
    float buildingX = i * 120 - parallaxOffset % 120;
    float buildingHeight = 100 + (noise(i * 0.3) * 150);
    
    // Only draw visible buildings
    if (buildingX > camera.x - 150 && buildingX < camera.x + width) {
      // Building silhouette
      fill(20, 25, 40);
      rect(buildingX, height - buildingHeight - 100, 100, buildingHeight);
      
      // Windows
      fill(neonOrange, 50 + random(50));
      for (int j = 0; j < 6; j++) {
        for (int k = 0; k < int(buildingHeight/20); k++) {
          if (random(1) > 0.7) {
            rect(buildingX + 10 + j*15, height - buildingHeight - 90 + k*20, 10, 15);
          }
        }
      }
    }
  }
  
  // Add billboard with Blade Runner style advertisement
  float billboardX = (width/2 - parallaxOffset) % (width*2);
  if (billboardX > camera.x - 300 && billboardX < camera.x + width) {
    drawBillboard(billboardX, height - 350);
  }
}

// Draw corporate tower for level 2
void drawCorporateTower() {
  // Main tower structure
  fill(10, 15, 25);
  stroke(neonBlue, 100);
  strokeWeight(2);
  rect(camera.x + width/2 - 200, 0, 400, height - 100);
  
  // Windows/lights pattern
  noStroke();
  for (int y = 30; y < height - 120; y += 40) {
    for (int x = 0; x < 10; x++) {
      if (random(1) > 0.4) {
        fill(neonOrange, 100 + random(100));
      } else {
        fill(neonPink, 100 + random(100));
      }
      rect(camera.x + width/2 - 180 + x * 40, y, 30, 25);
    }
  }
  
  // Corporate logo
  drawCorporateLogo(camera.x + width/2, 150);
  
  // Neon trim at base of tower
  stroke(neonPink, 150 + 50 * sin(frameCount * 0.05));
  strokeWeight(3);
  line(camera.x + width/2 - 220, height - 102, 
       camera.x + width/2 + 220, height - 102);
}

// Draw corporate logo
void drawCorporateLogo(float x, float y) {
  pushMatrix();
  translate(x, y);
  
  // Logo background
  noStroke();
  fill(0);
  ellipse(0, 0, 100, 100);
  
  // Outer ring
  noFill();
  stroke(neonBlue, 200);
  strokeWeight(3);
  ellipse(0, 0, 90, 90);
  
  // Inner design - eye-like symbol
  stroke(neonPink);
  strokeWeight(2);
  ellipse(0, 0, 50, 40);
  
  // Pupil
  fill(neonOrange);
  noStroke();
  ellipse(0, 0, 15, 15);
  
  // Text below logo
  fill(neonBlue);
  textAlign(CENTER);
  textSize(14);
  text("TYRELL CORP", 0, 60);
  textSize(10);
  text("MORE HUMAN THAN HUMAN", 0, 75);
  
  popMatrix();
}

  // Draw billboard with Blade Runner style advertisement
  void drawBillboard(float x, float y) {
    // Billboard frame
    fill(20);
    stroke(neonOrange, 150);
    strokeWeight(2);
    rect(x, y, 250, 150);
    
    // Animated ad content
    pushMatrix();
    translate(x + 125, y + 75);
    
    // Japanese-style characters (animated)
    textSize(30);
    textAlign(CENTER, CENTER);
    float blinkRate = sin(frameCount * 0.1);
    
    if (blinkRate > 0) {
      fill(neonPink, 150 + 100 * blinkRate);
      text("新しい生活", 0, -20);
      
      fill(neonBlue, 150 + 100 * blinkRate);
      textSize(16);
      text("OFF-WORLD COLONIES", 0, 20);
      
      fill(neonOrange, 100 + 50 * blinkRate);
      textSize(12);
      text("A NEW LIFE AWAITS YOU", 0, 50);
    } else {
      // Alternate ad
      fill(neonBlue, 150 + 100 * abs(blinkRate));
      textSize(24);
      text("ATARI", 0, -30);
      
      fill(neonPink, 150 + 100 * abs(blinkRate));
      textSize(14);
      text("EXPERIENCE THE FUTURE", 0, 10);
      
      fill(255, 100 + 50 * abs(blinkRate));
      textSize(18);
      text("今すぐ購入", 0, 40);
    }
    
    popMatrix();
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
  
  if (currentLevel.levelNumber == 2) {
    text("VILLAIN DEFEATED", width/2, height/2 - 80);
  } else {
    text("LEVEL COMPLETE", width/2, height/2 - 80);
  }
  
  textFont(menuFont);
  fill(neonPink, 200 * neonFlicker);
  text("FINAL SCORE: " + player.score, width/2, height/2 - 20);
  
  if (currentLevel.levelNumber == 1) {
    fill(neonOrange, 200 * neonFlicker);
    text("LEVEL 2 UNLOCKED", width/2, height/2 + 40);
  } else if (currentLevel.levelNumber == 2) {
    fill(neonOrange, 200 * neonFlicker);
    text("GAME COMPLETED", width/2, height/2 + 40);
    
    fill(neonPink, 150);
    textSize(16);
    text("\"ALL THOSE MOMENTS WILL BE LOST IN TIME, LIKE TEARS IN RAIN.\"", 
         width/2, height/2 + 100);
    textSize(14);
    text("- ROY BATTY", width/2, height/2 + 125);
  }
  
    fill(neonBlue, 150 + 50 * sin(frameCount * 0.1));
    textSize(18);
    text("PRESS ENTER TO CONTINUE", width/2, height - 100);
    
    // After a few seconds, allow the player to press Enter to continue
    if (frameCount % 180 < 90) {
      fill(255);
      text("→", width/2 + 160, height - 100);
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
