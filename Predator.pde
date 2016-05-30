class Predator {

  PVector posicion;
  PVector velocidad;
  PVector objetivo;
  int size;
  color col;
  float life;
  
  
  Predator() {
    
    posicion = new PVector(size/2,size/2);
    velocidad = new PVector(0,0);
    objetivo = new PVector(0,0);
    size = 40;
    col = color(#000000);
    life = 0;
  
  }
  
  void update() {
    
    life += 0.03;
    int vel = 2;
    PVector delta = objetivo.copy();
    delta.sub(posicion);
    delta.mult(0.6);
    velocidad = new PVector(vel*(1-2*noise(life)), vel*(1-2*noise(life + 1000)));
    posicion.add(velocidad);
    posicion.add(delta);
    
    if (posicion.x < 0) posicion.x = 0;
    else if (posicion.x > width) posicion.x = width;
    
    if (posicion.y < 0) posicion.y = 0;
    else if (posicion.y > height) posicion.y = height;
    
    if ((frameCount % 150 == 0) && (size > 30)) size--;
  
  }
  
  void setTarget(PVector objetivo_) {
  
    objetivo = objetivo_.copy();
    
  }
  
  void eat(Player player) {
  
    Rectangle predator = new Rectangle(int(posicion.x), int(posicion.y), size, size);
    Rectangle py = new Rectangle(int(player.posicion.x), int(player.posicion.y), player.size, player.size);
    
    if ((player.isPlaying()) && (predator.intersects(py))) {
      
      size = size + 30;
      player.dead();
      
    }
  }
  
  void display() {
    stroke(col);
    strokeWeight(2);
    noFill();
    pushMatrix();
    translate(posicion.x, posicion.y);
    rect(0, 0, size, size);
    popMatrix();
  
  }


}