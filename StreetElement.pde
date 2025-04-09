// StreetElement class for decorative elements
class StreetElement extends Environment {
  PImage texture;
  String elementType;
  
  StreetElement(float x, float y, String type) {
    super(x, y);
    elementType = type;
    
    // In a real game, you'd load different textures based on type
    // Here we'll just use different colors
    if (type.equals("trash")) {
      envColor = color(60, 55, 50);
      size = 15;
    } else if (type.equals("puddle")) {
      envColor = color(20, 30, 50, 100);
      size = 40;
    } else if (type.equals("neon")) {
      envColor = color(neonPink);
      size = 5;
    }
  }
  
  void display() {
    if (elementType.equals("trash")) {
      fill(envColor);
      noStroke();
      rect(position.x, position.y, size, size);
    } else if (elementType.equals("puddle")) {
      fill(envColor);
      noStroke();
      ellipse(position.x, position.y, size, size/4);
      
      // Reflection effect
      fill(neonBlue, 50);
      ellipse(position.x, position.y, size/2, size/8);
    } else if (elementType.equals("neon")) {
      // Neon light effect
      for (int i = 0; i < 3; i++) {
        fill(neonPink, 150 - i*50);
        noStroke();
        ellipse(position.x, position.y, size + i*3, size + i*3);
      }
    }
  }
}
