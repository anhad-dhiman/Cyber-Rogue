// GameObject is the parent class for all game objects
abstract class GameObject {
  PVector position;
  PVector velocity;
  PVector acceleration;
  float size;
  
  GameObject(float x, float y) {
    position = new PVector(x, y);
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    size = 30;
  }
  
  abstract void update();
  abstract void display();
}
