class WarpCam {
  
  ArrayList<PVector> canonicalPoints;
  boolean[] lockedPoints = new boolean[4];
  int margin, radius;
  XML xml;
  color col;
  int stk;
  
  WarpCam() {
  
      margin = 50;
      radius = 30;
      
      stk = 2;
      col = color(#1ED33D);
      
      canonicalPoints = new ArrayList<PVector>();
      
      xml = loadXML("settings.xml");
      XML[] children = xml.getChildren("point");
         
      for (int i = 0; i < 4; i++) {
        canonicalPoints.add(new PVector(0,0));
      }
      
      loadSettings();
      
      for (int i = 0; i < 4; i++) {
        
        lockedPoints[i] = false;
      
      }
  
  }
  
  float getDistance(int i) {
    
    return sqrt(pow((mouseX - 260 - canonicalPoints.get(i).x),2) + pow((mouseY - 40 - canonicalPoints.get(i).y),2));
  
  }
  
  void update(int i) {
  
    canonicalPoints.get(i).x = mouseX-260;
    canonicalPoints.get(i).y = mouseY-40;
  }

  void loadSettings() {
      XML[] children = xml.getChildren("point");
         
      for (int i = 0; i < 4; i++) {
        canonicalPoints.set(children[i].getInt("id"), new PVector(children[i].getFloat("x"), children[i].getFloat("y")));
      }
  }
  
  
  void saveSettings() {
      for (int i = 0; i < 4; i++) {
        xml.getChildren("point")[i].setFloat("x",canonicalPoints.get(i).x);
        xml.getChildren("point")[i].setFloat("y",canonicalPoints.get(i).y);
        println(xml.getChildren("point")[i]);
      }
      saveXML(xml, "data/settings.xml");
  }
  
  void lock(int i) {
   
    lockedPoints[i] = true;
    
  }
  
  void unlock(int i) {
   
    lockedPoints[i] = false;
    
  }
  
  void display() {

    noStroke();
    strokeWeight(stk);
    
    fill(0,100);
    rect(15,5,100,60);

    stroke(col);

    fill(255);
    textSize(12);
    text("Predator_v1.0\r\nMedialab Prado\r\nCalibration", 20, 20);
    noFill();
    
    fill(col);
    for (int i = 0; i < 3; i++) {
      
      line(canonicalPoints.get(i).x, canonicalPoints.get(i).y, canonicalPoints.get(i+1).x, canonicalPoints.get(i+1).y);
      
      if (lockedPoints[i]) fill(col,150);
      else noFill();
      
      ellipse(canonicalPoints.get(i).x, canonicalPoints.get(i).y, 2*radius, 2*radius);
    
    }
    
    line(canonicalPoints.get(3).x, canonicalPoints.get(3).y, canonicalPoints.get(0).x, canonicalPoints.get(0).y);
    
    if (lockedPoints[3]) fill(col,150);
    else noFill();
    
    ellipse(canonicalPoints.get(3).x, canonicalPoints.get(3).y, 2*radius, 2*radius);

    
  }

}