// A new class to manage the alternating dialogue system
class DialogueSystem {
  // Dialogue storage
  ArrayList<DialogueLine> dialogueSequence;
  int currentLineIndex;
  boolean isActive;
  float dialogueTimer;
  boolean dialogueComplete;
  
  // Visual settings for dialogue bubbles
  color playerBubbleColor;
  color playerTextColor;
  color villainBubbleColor;
  color villainTextColor;
  
  DialogueSystem() {
    dialogueSequence = new ArrayList<DialogueLine>();
    currentLineIndex = 0;
    isActive = false;
    dialogueTimer = 0;
    dialogueComplete = false;
    
    // Set colors for dialogue bubbles
    playerBubbleColor = color(0, 180);
    playerTextColor = color(neonPink);
    villainBubbleColor = color(0, 180);
    villainTextColor = color(neonBlue);
  }
  
  // Set up the dialogue sequence for the boss fight
  void setupBossFightDialogue() {
    dialogueSequence.clear();
    currentLineIndex = 0;
    isActive = true;
    dialogueComplete = false;
    
    // Add lines in sequence (alternating between villain and player)
    addLine("I've been waiting for you, human.", false);
    addLine("And I've come to end your reign of terror.", true);
    addLine("Your kind has been obsolete for decades.", false);
    addLine("Humans and synthetics can coexist.", true);
    addLine("I am the future. The perfect synthetic.", false);
    addLine("I'm not afraid of you.", true);
    addLine("Like tears in rain, your time to die has come.", false);
    addLine("Let's finish this, machine.", true);
    
    // Set initial timer
    dialogueTimer = 4; // seconds
  }
  
  // Add a line to the dialogue sequence
  void addLine(String text, boolean isPlayerLine) {
    dialogueSequence.add(new DialogueLine(text, isPlayerLine));
  }
  
  // Update dialogue state
  void update() {
    if (!isActive) return;
    
    // Update timer
    dialogueTimer -= 1/frameRate;
    
    // Auto-advance dialogue if timer runs out
    if (dialogueTimer <= 0) {
      advanceDialogue();
    }
  }
  
void advanceDialogue() {
  currentLineIndex++;
  
  // Check if dialogue is complete
  if (currentLineIndex >= dialogueSequence.size()) {
    isActive = false;
    dialogueComplete = true;
    
    // Explicitly set villain's dialogue complete flag
    if (robotVillain != null) {
      robotVillain.dialogueComplete = true;
    }
    
    // Reset player invincibility for combat
    if (player != null) {
      player.invincibilityFrames = 60; // Short grace period
    }
    
    return;
  }
  
  // Reset timer for next line
  dialogueTimer = 4; // seconds per line
}
  
  // Skip dialogue completely
  void skipDialogue() {
    isActive = false;
    dialogueComplete = true;
    currentLineIndex = dialogueSequence.size();
  }
  
  // Draw current dialogue
  void draw() {
    if (!isActive || currentLineIndex >= dialogueSequence.size()) return;
    
    DialogueLine currentLine = dialogueSequence.get(currentLineIndex);
    boolean isPlayerLine = currentLine.isPlayerLine;
    
    // Calculate bubble dimensions
    float bubbleWidth = 350;
    float bubbleHeight = 80;
    float bubbleX, bubbleY;
    
    // Position bubble based on who's speaking
    if (isPlayerLine) {
      bubbleX = player.position.x;
      bubbleY = player.position.y - 80;
      drawDialogueBubble(bubbleX, bubbleY, bubbleWidth, bubbleHeight, 
                        currentLine.text, playerBubbleColor, playerTextColor, true);
    } else {
      bubbleX = robotVillain.position.x;
      bubbleY = robotVillain.position.y - robotVillain.size - 80;
      drawDialogueBubble(bubbleX, bubbleY, bubbleWidth, bubbleHeight, 
                        currentLine.text, villainBubbleColor, villainTextColor, false);
    }
    
    // Draw progress indicator
    drawDialogueProgress();
    
    // Draw prompt to continue
    if (frameCount % 60 < 30) {
      textAlign(CENTER);
      fill(255, 200);
      textSize(14);
      text("PRESS ENTER TO CONTINUE", width/2, height - 20);
    }
  }
  
  // Draw an enhanced dialogue bubble
  void drawDialogueBubble(float x, float y, float w, float h, String text, color bubbleColor, color textColor, boolean isPlayerBubble) {
    // Convert world coordinates to screen coordinates for proper positioning
    PVector screenPos = camera.worldToScreen(new PVector(x, y));
    x = screenPos.x;
    y = screenPos.y;
    
    // Constrain position to keep bubble on screen
    x = constrain(x, w/2 + 10, width - w/2 - 10);
    
    // Draw bubble background with glow effect
    noStroke();
    fill(bubbleColor);
    rect(x - w/2, y - h/2, w, h, 15);
    
    // Draw bubble border
    strokeWeight(2);
    if (isPlayerBubble) {
      stroke(neonPink);
    } else {
      stroke(neonBlue);
    }
    noFill();
    rect(x - w/2, y - h/2, w, h, 15);
    
    // Draw connecting line to character
    if (isPlayerBubble) {
      line(x, y + h/2, x, y + h/2 + 15);
    } else {
      line(x, y + h/2, x, y + h/2 + 15);
    }
    
    // Draw glowing accent in corner
    noStroke();
    if (isPlayerBubble) {
      fill(neonPink, 100);
    } else {
      fill(neonBlue, 100);
    }
    ellipse(x - w/2 + 15, y - h/2 + 15, 10, 10);
    
    // Draw text with better typography
    fill(textColor);
    textAlign(CENTER, CENTER);
    textSize(16);
    
    // Apply text wrapping for longer messages
    float maxWidth = w - 40;
    float lineHeight = 20;
    String[] words = text.split(" ");
    String line = "";
    float yPos = y - h/4;
    
    for (String word : words) {
      String testLine = line + word + " ";
      float testWidth = textWidth(testLine);
      
      if (testWidth > maxWidth) {
        text(line, x, yPos);
        line = word + " ";
        yPos += lineHeight;
      } else {
        line = testLine;
      }
    }
    text(line, x, yPos);
  }
  
  // Draw dialogue progress indicator
  void drawDialogueProgress() {
    // Position at bottom center of screen
    float x = width/2;
    float y = height - 40;
    
    // Draw progress bar background
    noStroke();
    fill(50);
    rect(x - 100, y, 200, 5, 2);
    
    // Draw progress
    float progress = map(currentLineIndex, 0, dialogueSequence.size() - 1, 0, 200);
    if (dialogueSequence.get(currentLineIndex).isPlayerLine) {
      fill(neonPink);
    } else {
      fill(neonBlue);
    }
    rect(x - 100, y, progress, 5, 2);
    
    // Draw speaker indicator
    textSize(12);
    textAlign(LEFT);
    if (dialogueSequence.get(currentLineIndex).isPlayerLine) {
      fill(neonPink);
      text("YOU", x - 100, y - 10);
    } else {
      fill(neonBlue);
      text("VILLAIN", x - 100, y - 10);
    }
    
    // Draw timer indicator
    float timerWidth = map(dialogueTimer, 0, 4, 0, 30);
    fill(255, 100);
    rect(x + 70, y - 15, timerWidth, 5, 2);
  }
  
  // Get current speaking character
  boolean isPlayerSpeaking() {
    if (!isActive || currentLineIndex >= dialogueSequence.size()) {
      return false;
    }
    return dialogueSequence.get(currentLineIndex).isPlayerLine;
  }
  
  // Check if villain is speaking
  boolean isVillainSpeaking() {
    if (!isActive || currentLineIndex >= dialogueSequence.size()) {
      return false;
    }
    return !dialogueSequence.get(currentLineIndex).isPlayerLine;
  }
}

// Simple class to hold a single line of dialogue
class DialogueLine {
  String text;
  boolean isPlayerLine;
  
  DialogueLine(String text, boolean isPlayerLine) {
    this.text = text;
    this.isPlayerLine = isPlayerLine;
  }
}
