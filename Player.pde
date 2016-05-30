class Player {

  PVector posicion, objetivo;
  int size;
  float distancia;
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
    distancia = pow((posicion.x - corner.x), 2) + pow((posicion.y - corner.y), 2);

  
  }
  
  void update(PVector obj) {
    
    objetivo = obj.copy();
    PVector delta = obj.copy().sub(posicion);
    delta.mult(0.4);
    posicion.add(delta);
    distancia = pow((posicion.x - corner.x), 2) + pow((posicion.y - corner.y), 2);
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
    
    if (dist < pow(dispersion,2)) return true;
    else return false;
  
  }
  
  void display() {
    
    if (visible) {
      rectMode(CORNER);
      stroke(col);
      strokeWeight(2);
      noFill();
      pushMatrix();
      translate(posicion.x, posicion.y);
      rect(0, 0, size, size);
      popMatrix();
      
      int posfachadaX = int(map(posicion.x, 0 , 640, 0, fachada.width));
      int posfachadaY = int(map(posicion.y, 0 , 480, 0, fachada.height));
      int sizefachada = int(map(size, 0 , 640, 0, fachada.width));
      
      fachada.pushMatrix();
      fachada.beginDraw();
      fachada.stroke(255);
      fachada.translate(posfachadaX, posfachadaY);
      fachada.rect(0,0, sizefachada, sizefachada);
      fachada.endDraw();
      fachada.popMatrix();
      
    }
  
  }


}