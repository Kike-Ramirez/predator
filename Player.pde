class Player {

  PVector posicion, objetivo;
  int size;
  color col;
  float life;
  boolean alive, visible;
  
  Player(PVector pos) {
    
    posicion = pos.copy();
    objetivo = pos.copy();
    size = 50;
    col = color(#444444);
    life = 0;
    alive = true;
    visible = true;
  
  }
  
  void update(PVector obj) {
    
    objetivo = obj.copy();
    PVector delta = obj.copy().sub(posicion);
    delta.mult(0.4);
    posicion.add(delta);
    life = 0;
  
  }
  
  void tick() {
  
    life++;
    if (life > 60) alive = false;
    
  }
  
  void dead() {
  
    visible = false;
  
  }
  
  boolean isAlive() {
    
    return alive;
    
  }

  boolean isPlaying() {
    
    return visible;
    
  }
  
  boolean checkId(PVector punto) {
  
    float dist = pow((posicion.x - punto.x), 2) + pow((posicion.y - punto.y), 2);
    
    if (dist < 10000) return true;
    else return false;
  
  }
  
  void display() {
    
    if (visible) {
      rectMode(CENTER);
      stroke(col);
      strokeWeight(2);
      noFill();
      pushMatrix();
      translate(posicion.x, posicion.y);
      rect(0, 0, size, size);
      popMatrix();
    }
  
  }


}