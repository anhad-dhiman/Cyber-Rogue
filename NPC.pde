// NPC class for non-playable characters
class NPC extends Character {
  String npcType;
  String[] dialogues;
  int currentDialogue;
  
  NPC(float x, float y, String type) {
    super(x, y);
    npcType = type;
    
    // Set up dialogues based on NPC type
    if (type.equals("informant")) {
      dialogues = new String[] {
        "Watch out for the security drones!",
        "The corporate tower is heavily guarded.",
        "I heard they're upgrading security systems."
      };
    } else if (type.equals("vendor")) {
      dialogues = new String[] {
        "Need some upgrades?",
        "I've got the best tech in town.",
        "These streets are getting more dangerous."
      };
    } else {
      dialogues = new String[] {
        "Just another day in this cyberpunk hell.",
        "The rain never stops in this city.",
        "Stay low, stay alive."
      };
    }
    
    currentDialogue = 0;
  }
  
  void update() {
    // NPCs don't move in this implementation
  }
  
  void display() {
    // Draw NPC based on type
    if (npcType.equals("informant")) {
      fill(neonOrange);
    } else if (npcType.equals("vendor")) {
      fill(neonBlue);
    } else {
      fill(150);
    }
    
    // Draw body
    stroke(50);
    ellipse(position.x, position.y - 15, size, size);
    
    // Draw legs
    line(position.x - 5, position.y, position.x - 10, position.y + 20);
    line(position.x + 5, position.y, position.x + 10, position.y + 20);
    
    // Draw hat
    noStroke();
    ellipse(position.x, position.y - 25, size * 0.8, 10);
  }
  
  String getNextDialogue() {
    String dialogue = dialogues[currentDialogue];
    currentDialogue = (currentDialogue + 1) % dialogues.length;
    return dialogue;
  }
  
  void move(float direction) {
    // NPCs don't move in this implementation
  }
  
  void jump() {
    // NPCs don't jump in this implementation
  }
}
