// Character is an abstract class for all characters
abstract class Character extends GameObject {
  int health;
  float speed;
  float jumpForce;
  boolean isOnGround;
  
  Character(float x, float y) {
    super(x, y);
    health = 3;
    speed = 5;
    jumpForce = 15;
    isOnGround = true;
  }
  
  abstract void move(float direction);
  abstract void jump();
}
