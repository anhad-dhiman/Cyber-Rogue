// Abstract class for obstacles
abstract class Obstacle extends GameObject {
  boolean isActive;
  
  Obstacle(float x, float y) {
    super(x, y);
    isActive = true;
  }
  
  abstract void activate();
  abstract void deactivate();
}
