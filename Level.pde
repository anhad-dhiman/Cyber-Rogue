// Level class to manage level-specific data
class Level {
  int levelNumber;
  String levelName;
  int targetScore;
  
  Level(int number, String name) {
    levelNumber = number;
    levelName = name;
    targetScore = 100 * number;
  }
}

// Enums for state management
enum PlayerState {
  IDLE, RUNNING, JUMPING, HIDING, DETECTED
}

enum DroneState {
  PATROLLING, SEARCHING, PURSUING, RETURNING
}
