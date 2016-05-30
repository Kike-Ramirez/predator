class Predator {

  PVector posicion;
  PVector velocidad;
  PVector objetivo;
  int size;
  float distancia;
  color col;
  float life;
  float distmin;  
  int status;
  
  Predator() {
    
    posicion = new PVector(corner.x, corner.y);
    distancia = pow((posicion.x - corner.x), 2) + pow((posicion.y - corner.y), 2);
    velocidad = new PVector(0,0);
    objetivo = new PVector(corner.x, corner.y);
    size = 40;
    col = color(#000000);
    life = 0;
    distmin = 1000000;
    status = 0; // 0: idle; 1: seeking; 2: killing
  
  }
  
  void update() {
    
    life += 0.03;
    distancia = pow((posicion.x - corner.x), 2) + pow((posicion.y - corner.y), 2);
    int vel = 2;
    velocidad = new PVector(vel*(1-2*noise(life)), vel*(1-2*noise(life + 1000)));
    posicion.add(velocidad);

    PVector delta = objetivo.copy();
    delta.sub(posicion);
    delta.mult(predator_Speed);  

    
    if (status <= 1) {
      
      float distancia2 = pow((posicion.x + size - corner.x), 2) + pow((posicion.y + size - corner.y), 2);
      
      if (distancia2 > pow(radio1/2, 2)) posicion.sub(velocidad);
      if ((objetivo.x == corner.x) && (objetivo.y == corner.y)) posicion.add(delta);
    
    }
    
    if (status == 1) {
    
      posicion.add(delta);  
      float distancia2 = pow((posicion.x + size - corner.x), 2) + pow((posicion.y + size - corner.y), 2);
      
      if ((distancia2 > pow(radio1/2, 2)) && (distancia2 > distancia)) posicion.sub(delta);
      
    } 
    
    else if (status == 2) {
      
      posicion.add(delta);
      
    }
    
    
    if (posicion.x < 0) posicion.x = 0;
    else if (posicion.x + size > width) posicion.x = width-size;
    
    if (posicion.y < 0) posicion.y = 0;
    else if (posicion.y + size > height) posicion.y = height-size;
    
    if ((frameCount % 50 == 0) && (size > 30)) size--;
  
  }
  
  void setTarget(ArrayList<Player> objetivos_) {
    
    int numobjetivo = 0;
    distmin = 1000000;
    boolean haytarget = false;
    status = 0;
    
    for (int i=0; i < objetivos_.size(); i++) {
      
      float distparcial = objetivos_.get(i).distancia;
      if ((distparcial < pow(radio1/2, 2) && (distparcial < distmin)) && (objetivos_.get(i).isPlaying())) {
        
        distmin = objetivos_.get(i).distancia;
        numobjetivo = i;
        haytarget = true;
        status = 2;
        
      }

      else if ((status==0) &&(distparcial < pow(radio2/2, 2) && (distparcial < distmin)) && (objetivos_.get(i).isPlaying())) {
        
        distmin = objetivos_.get(i).distancia;
        numobjetivo = i;
        haytarget = true;
        status = 1;
        
      }
      
    }
    
    if (haytarget) objetivo = objetivos_.get(numobjetivo).posicion.copy();
    else objetivo = corner.copy();
    
  }
  
  void eat(Player player) {
  
    Rectangle predator = new Rectangle(int(posicion.x), int(posicion.y), size, size);
    Rectangle py = new Rectangle(int(player.posicion.x), int(player.posicion.y), player.size, player.size);
    
    if ((player.isPlaying()) && (predator.intersects(py))) {
      
      if (size <= 80) size = size + 10;
      player.dead();
      
    }
  }
  
  void display() {
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
    fachada.stroke(0);
    fachada.translate(posfachadaX, posfachadaY);
    fachada.rect(0,0, sizefachada, sizefachada);
    fachada.endDraw();
    fachada.popMatrix();
  
  }


}