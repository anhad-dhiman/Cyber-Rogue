// PowerUp interface for collectible power-ups
interface PowerUp extends Collectible {
  void applyEffect();
  int getDuration();
}
