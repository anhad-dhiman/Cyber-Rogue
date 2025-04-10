// Modified Player class to look more human with cyberpunk elements
class CyberpunkPlayer extends Player {
  boolean facingRight;
  float animationFrame;
  
  // Dialogue system for player
  boolean isTalking;
  String[] dialogueLines;
  int currentLine;
  float dialogueTimer;
  
  CyberpunkPlayer(float x, float y) {
    super(x, y);
    facingRight = true;
    animationFrame = 0;
    
    // Initialize dialogue system
    isTalking = false;
    dialogueLines = new String[] {
      "I've come to end your reign of terror.",
      "Humans and synthetics can coexist.",
      "I'm not afraid of you.",
      "Let's finish this, machine."
    };
    currentLine = 0;
    dialogueTimer = 0;
  }
  
  void update() {
    super.update();
    
    // Update dialogue timer if talking
    if (isTalking) {
      dialogueTimer -= 1/frameRate;
      if (dialogueTimer <= 0) {
        advanceDialogue();
      }
    }
  }
  
  void display() {
    // Flicker when invincible
    if (invincibilityFrames > 0 && frameCount % 5 > 2) {
      return;
    }
    
    // Update animation frame
    if (state == PlayerState.RUNNING) {
      animationFrame += 0.2;
    } else {
      animationFrame = 0;
    }
    
    // Draw the human player with cyberpunk elements
    pushMatrix();
    translate(position.x, position.y - 15);
    
    // Facing direction
    if ((velocity.x < 0 && facingRight) || (velocity.x > 0 && !facingRight)) {
      facingRight = velocity.x > 0;
    }
    if (!facingRight) {
      scale(-1, 1);
    }
    
    // Draw based on state
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
    
    popMatrix();
    
    // Draw state indicator (for debugging)
    fill(255);
    textSize(12);
    text(state.toString(), position.x, position.y - 50);
    
    // Draw dialogue if talking
    if (isTalking) {
      drawDialogue();
    }
  }
  
  void drawDialogue() {
    float bubbleWidth = 300;
    float bubbleHeight = 60;
    float bubbleX = position.x;
    float bubbleY = position.y - 80;
    
    // Draw speech bubble
    fill(0, 180);
    stroke(neonPink);
    strokeWeight(2);
    rect(bubbleX - bubbleWidth/2, bubbleY - bubbleHeight/2, 
         bubbleWidth, bubbleHeight, 10);
         
    // Draw text
    fill(neonPink);
    textAlign(CENTER, CENTER);
    textSize(16);
    text(dialogueLines[currentLine], bubbleX, bubbleY);
    
    // Draw progress dots
    for (int i = 0; i < dialogueLines.length; i++) {
      if (i == currentLine) fill(neonBlue);
      else fill(100);
      ellipse(bubbleX - 10 * dialogueLines.length/2 + i * 10, 
              bubbleY + bubbleHeight/2 - 10, 5, 5);
    }
  }
  
  void startDialogue() {
    isTalking = true;
    currentLine = 0;
    dialogueTimer = 3; // seconds per line
  }
  
  void advanceDialogue() {
    currentLine++;
    if (currentLine >= dialogueLines.length) {
      isTalking = false;
    } else {
      dialogueTimer = 3; // Reset timer for next line
    }
  }
  
  void drawIdlePlayer() {
    // Body - more human proportions
    stroke(0);
    strokeWeight(1);
    
    // Legs
    float legMovement = 0;
    fill(40);
    rect(-8, 0, 6, 25, 2); // Left leg
    rect(2, 0, 6, 25, 2);  // Right leg
    
    // Torso - cyberpunk leather jacket
    fill(30);
    rect(-10, -25, 20, 25, 3);
    
    // Neon jacket details
    stroke(neonBlue);
    line(-8, -23, -8, -5);
    stroke(neonPink);
    line(8, -23, 8, -5);
    
    // Arms
    stroke(0);
    fill(40);
    rect(-12, -20, 4, 15, 2); // Left arm
    rect(8, -20, 4, 15, 2);   // Right arm
    
    // Head
    fill(200, 180, 160); // Skin tone
    ellipse(0, -33, 16, 18);
    
    // Cybernetic eye implant
    stroke(neonPink);
    line(-5, -35, -1, -35);
    
    // Hair
    fill(30);
    noStroke();
    arc(0, -40, 16, 10, PI, TWO_PI);
    
    // Eyes
    fill(255);
    ellipse(-3, -33, 3, 3);
    ellipse(3, -33, 3, 3);
    
    // Pupils
    fill(0);
    ellipse(-3, -33, 1.5, 1.5);
    ellipse(3, -33, 1.5, 1.5);
  }
  
  void drawRunningPlayer() {
    // Calculate leg movement based on animation frame
    float legOffset = sin(animationFrame) * 8;
    
    // Body - more human proportions
    stroke(0);
    strokeWeight(1);
    
    // Legs with movement
    fill(40);
    rect(-8, 0, 6, 25 + legOffset, 2); // Left leg
    rect(2, 0, 6, 25 - legOffset, 2);  // Right leg
    
    // Torso - cyberpunk leather jacket
    fill(30);
    rect(-10, -25, 20, 25, 3);
    
    // Neon jacket details with animation
    stroke(neonBlue, 150 + 50 * sin(frameCount * 0.1));
    line(-8, -23, -8, -5);
    stroke(neonPink, 150 + 50 * sin(frameCount * 0.1 + PI));
    line(8, -23, 8, -5);
    
    // Arms with movement
    stroke(0);
    fill(40);
    rect(-12, -20, 4, 15 - legOffset/2, 2); // Left arm moves opposite to legs
    rect(8, -20, 4, 15 + legOffset/2, 2);   // Right arm
    
    // Head
    fill(200, 180, 160); // Skin tone
    ellipse(0, -33, 16, 18);
    
    // Cybernetic eye implant
    stroke(neonPink);
    line(-5, -35, -1, -35);
    
    // Hair
    fill(30);
    noStroke();
    arc(0, -40, 16, 10, PI, TWO_PI);
    
    // Eyes
    fill(255);
    ellipse(-3, -33, 3, 3);
    ellipse(3, -33, 3, 3);
    
    // Pupils
    fill(0);
    ellipse(-3, -33, 1.5, 1.5);
    ellipse(3, -33, 1.5, 1.5);
  }
  
  void drawJumpingPlayer() {
    // Body - more human proportions
    stroke(0);
    strokeWeight(1);
    
    // Legs tucked for jump
    fill(40);
    rect(-8, 0, 6, 20, 2); // Left leg
    rect(2, 0, 6, 20, 2);  // Right leg
    
    // Torso - cyberpunk leather jacket
    fill(30);
    rect(-10, -25, 20, 25, 3);
    
    // Neon jacket details
    stroke(neonBlue);
    line(-8, -23, -8, -5);
    stroke(neonPink);
    line(8, -23, 8, -5);
    
    // Arms positioned for jump
    stroke(0);
    fill(40);
    rect(-15, -20, 4, 15, 2); // Left arm out
    rect(11, -20, 4, 15, 2);  // Right arm out
    
    // Head
    fill(200, 180, 160); // Skin tone
    ellipse(0, -33, 16, 18);
    
    // Cybernetic eye implant
    stroke(neonPink);
    line(-5, -35, -1, -35);
    
    // Hair windblown effect
    fill(30);
    noStroke();
    arc(0, -40, 16, 8, PI, TWO_PI);
    
    // Determined eyes
    fill(255);
    ellipse(-3, -33, 3, 3);
    ellipse(3, -33, 3, 3);
    
    // Pupils
    fill(0);
    ellipse(-3, -33, 1.5, 1.5);
    ellipse(3, -33, 1.5, 1.5);
  }
  
  void drawHidingPlayer() {
    // Body crouched and nearly invisible
    stroke(0, 60);
    strokeWeight(1);
    
    // Crouched position
    fill(30, 60);
    ellipse(0, 0, 30, 15);
    
    // Head peeking
    fill(200, 180, 160, 60); // Transparent skin tone
    ellipse(0, -10, 12, 10);
    
    // Eyes still visible but dimmer
    fill(255, 100);
    ellipse(-3, -10, 3, 2);
    ellipse(3, -10, 3, 2);
    
    // Neon details very dim but still present
    stroke(neonBlue, 30);
    point(-5, -5);
    stroke(neonPink, 30);
    point(5, -5);
    
    // Stealth indicator
    noStroke();
    fill(neonBlue, 30 + 20 * sin(frameCount * 0.2));
    for (int i = 0; i < 3; i++) {
      ellipse(0, -25, 5 + i*2, 2 + i);
    }
  }
  
  void drawDetectedPlayer() {
    // Body - alarmed pose
    stroke(neonOrange);
    strokeWeight(2);
    
    // Legs
    fill(40);
    rect(-10, 0, 7, 25, 2); // Left leg wider stance
    rect(3, 0, 7, 25, 2);   // Right leg wider stance
    
    // Torso - glowing danger indicator
    fill(30);
    rect(-10, -25, 20, 25, 3);
    
    // Pulsing alert details
    float pulseAmount = sin(frameCount * 0.5) * 0.5 + 0.5;
    stroke(neonOrange, 200 * pulseAmount);
    line(-8, -23, -8, -5);
    line(8, -23, 8, -5);
    
    // Arms raised in alarm
    stroke(neonOrange);
    fill(40);
    rect(-17, -25, 4, 15, 2); // Left arm raised
    rect(13, -25, 4, 15, 2);  // Right arm raised
    
    // Head
    fill(200, 180, 160); // Skin tone
    ellipse(0, -33, 16, 18);
    
    // Cybernetic eye implant flashing
    stroke(neonOrange, 200 * pulseAmount);
    line(-5, -35, -1, -35);
    
    // Hair
    fill(30);
    noStroke();
    arc(0, -40, 16, 10, PI, TWO_PI);
    
    // Wide eyes
    fill(255);
    ellipse(-4, -33, 4, 4);
    ellipse(4, -33, 4, 4);
    
    // Pupils
    fill(0);
    ellipse(-4, -33, 2, 2);
    ellipse(4, -33, 2, 2);
    
    // Alert symbol above head
    fill(neonOrange, 200 * pulseAmount);
    triangle(0, -50, -7, -65, 7, -65);
    fill(0);
    text("!", 0, -58);
  }
  
  void fireProjectile() {
    // Don't allow firing during dialogue
    if (dialogueSystem != null && !dialogueSystem.dialogueComplete) {
      return;
    }
    
    // Create a player projectile aimed in the facing direction
    float targetX = facingRight ? position.x + 300 : position.x - 300;
    projectiles.add(new Projectile(
      position.x, 
      position.y - 15, 
      new PVector(targetX, position.y - 15), 
      true
    ));
    
    // Add a visual flash effect when firing
    fill(neonBlue, 150);
    noStroke();
    ellipse(position.x + (facingRight ? 20 : -20), position.y - 15, 15, 15);
  }
}
