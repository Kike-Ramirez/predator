class Predator {

  PVector posicion;
  PVector velocidad;
  int size;
  color col;
  float life;
  
  Predator() {
    
    posicion = new PVector(size/2,size/2);
    velocidad = new PVector(0,0);
    size = 40;
    col = color(#000000);
    life = 0;
  
  }
  
  void update() {
    
    life += 0.03;
    int vel = 2;
    velocidad = new PVector(vel*(1-2*noise(life)), vel*(1-2*noise(life + 1000)));
    posicion.add(velocidad);
    
    if (posicion.x < 0) posicion.x = 0;
    else if (posicion.x > width) posicion.x = width;
    
    if (posicion.y < 0) posicion.y = 0;
    else if (posicion.y > height) posicion.y = height;
    
    if ((frameCount % 60 == 0) && (size > 30)) size--;
  
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