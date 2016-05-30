import gab.opencv.*;
import processing.video.*;
import org.opencv.imgproc.Imgproc;
import org.opencv.core.MatOfPoint2f;
import org.opencv.core.Point;
import org.opencv.core.Size;

import org.opencv.core.Mat;
import org.opencv.core.CvType;
import java.awt.*;

import controlP5.*;

ControlP5 cp5;


Capture video;
// Movie video;

// Radiobutton de modo
RadioButton mode;
controlP5.Button load;
controlP5.Button save;

OpenCV opencv;
PImage warpedImage;
WarpCam warpCam;
Predator predator;
PVector corner = new PVector(0,98);
ArrayList<Player> players;
PGraphics fachada, previo;
int radio1 = 250*2;
int radio2 = 350*2;

// Status: 0 => Calibration; 1 => Instructions; 2 => Game 
int status = 2;

float predator_Speed;
float dispersion;

void setup() {
  size(1024,768);
  
  video = new Capture(this, 640, 480);
  
  //video = new Movie(this, "a2.avi");
  fachada = createGraphics(192, 157);
  previo = createGraphics(640,480);
  
  opencv = new OpenCV(this, 640, 480);
  
  warpCam = new WarpCam();
  predator = new Predator();
  predator_Speed = 0.012;
  dispersion = 70;
  
  opencv.startBackgroundSubtraction(5, 3, 0.5);
  
  //video.loop();
  //video.jump(80);
  
  video.start();
  
  warpedImage = createImage(640, 480, ARGB);  
  players = new ArrayList<Player>();
  
  cp5 = new ControlP5(this);
  mode = cp5.addRadioButton("Modo")
         .setPosition(40,200)
         .setSize(40,20)
         .setColorForeground(color(120))
         .setColorActive(color(255))
         .setColorLabel(color(255))
         .setItemsPerRow(1)
         .setSpacingColumn(50)
         .addItem("Calibration",0)
         .addItem("Game",2)
         .activate(1);
         ;
  
  // create a new button with name 'buttonA'
  load = cp5.addButton("load_Config")
     .setValue(0)
     .setPosition(40,300)
     .setSize(60,20)
     .setVisible(false)
     ;
  
  // and add another 2 buttons
  save = cp5.addButton("save_Config")
     .setValue(0)
     .setPosition(110,300)
     .setSize(60,20)
     .setVisible(false)
     ;
  
  cp5.addSlider("predator_Speed")
     .setPosition(40,260)
     .setRange(0,0.05)
     .setVisible(true);
     ;

  cp5.addSlider("dispersion")
     .setPosition(40,280)
     .setRange(0,100)
     .setVisible(true);
     ;

}

void draw() {
    
  background(0);
  
  fill(255);
  textSize(12);
  text("Predator by Carl-Johan Rosen / Henrik Wrangel",40, 600);
  text("Adaptación para fachada digital: Kike Ramírez (kike@vjspain.com)",40, 620);
  text("Interactivos'16 - Medialab Prado",40, 640);
  
  fachada.beginDraw();
  fachada.background(#7162FF);
  int radiofachada1 = int(map(radio1,0,640,0,fachada.width));
  int radiofachada2 = int(map(radio2,0,640,0,fachada.width));
  int posfachadaX = int(map(corner.x, 0, 640, 0, fachada.width));
  int posfachadaY = int(map(corner.y, 0, 480, 0, fachada.height));
  
  fachada.pushMatrix();
  fachada.translate(posfachadaX, posfachadaY);
  fachada.stroke(#0B0071);
  fachada.noFill();
  fachada.ellipse(0,0,radiofachada1, radiofachada1);
  fachada.ellipse(0,0,radiofachada2, radiofachada2);
  //fachada.rect(-posfachadaX, -posfachadaY, 72, 16); 
  //fachada.rect(-posfachadaX, -posfachadaY/2, 36, 16); 
  fachada.popMatrix();
  fachada.endDraw();
  
  pushMatrix();
  translate(260,40);
  
  if (status ==0) {
    // Calibration mode
    image(video, 0, 0);
    warpCam.display();
    
  }
  
  else if (status == 1) {
   
    // Instructions Mode
    background(0);
    text("Instructions Mode", 30, height/2);
    
  }
  
  else if (status == 2) {
    
    // Game Mode
    opencv.loadImage(video);
    opencv.toPImage(warpPerspective(warpCam.canonicalPoints, 640, 480), warpedImage);

    opencv.loadImage(warpedImage);
    image(warpedImage, 0, 0);
    
    //opencv.blur(20);
    //opencv.threshold(120);
    
    opencv.updateBackground();
    
    opencv.dilate();
    opencv.erode();
  
    noFill();
    stroke(255, 0, 0);
    strokeWeight(3);
    
    ArrayList<PVector> contours = new ArrayList<PVector>();
    
    for (Contour contour : opencv.findContours()) {
      Rectangle cuadrado = contour.getBoundingBox();
      PVector centro = new PVector(cuadrado.x, cuadrado.y);
      Boolean added = false;
      
      for (int i = 0; i < contours.size(); i++) {
      
        float dist = pow((centro.x - contours.get(i).x), 2) + pow((centro.y - contours.get(i).y), 2);
       
        if (dist < pow(dispersion,2)) {
        
          // Añadir valor a la lista
          added = true;
          float mediaX = 0.5 * (contours.get(i).x + centro.x);
          float mediaY = 0.5 * (contours.get(i).y + centro.y);
          contours.set(i, new PVector(mediaX,mediaY));
          
        }
      }
      
      if (!added) {
        contours.add(centro);
      }
      
      //contour.draw();
    }
    
    stroke(0);
    strokeWeight(1);
    ellipse(corner.x,corner.y,radio1,radio1);
    ellipse(corner.x,corner.y,radio2,radio2);
    stroke(255);
    for (int i = 0; i < contours.size(); i++) {
      
      Boolean added = false;
      
      for (int j = 0; j < players.size(); j++) {
        
        if (players.get(j).checkId(contours.get(i))) {
          
          added = true;
          players.get(j).update(contours.get(i));
          players.get(j).display();
          //rect(contours.get(i).x,contours.get(i).y,100,100);
        
        }
                
      }
      
      if (!added) players.add(new Player(contours.get(i)));
      
    }
    
    for (int i = players.size()-1; i >= 0; i--) {
    
      players.get(i).tick();
      predator.eat(players.get(i));
      if (!players.get(i).isAlive()) players.remove(i);
    
    } 
    
    predator.setTarget(players);
    
    predator.update();
    predator.display();
    
  }

  text(frameRate, 20, 20);
  text(predator.status, 20, 50);
  popMatrix();

  image(fachada,40,40);

}

void captureEvent(Capture c) {
  c.read();
}

//void movieEvent(Movie m) {
//  m.read();
//}


Mat getPerspectiveTransformation(ArrayList<PVector> inputPoints, int w, int h) {
  Point[] canonicalPoints = new Point[4];
  canonicalPoints[0] = new Point(w, 0);
  canonicalPoints[1] = new Point(0, 0);
  canonicalPoints[2] = new Point(0, h);
  canonicalPoints[3] = new Point(w, h);

  MatOfPoint2f canonicalMarker = new MatOfPoint2f();
  canonicalMarker.fromArray(canonicalPoints);

  Point[] points = new Point[4];
  for (int i = 0; i < 4; i++) {
    points[i] = new Point(inputPoints.get(i).x, inputPoints.get(i).y);
  }
  MatOfPoint2f marker = new MatOfPoint2f(points);
  return Imgproc.getPerspectiveTransform(marker, canonicalMarker);
}

Mat warpPerspective(ArrayList<PVector> inputPoints, int w, int h) {
  Mat transform = getPerspectiveTransformation(inputPoints, w, h);
  Mat unWarpedMarker = new Mat(w, h, CvType.CV_8UC1);    
  Imgproc.warpPerspective(opencv.getColor(), unWarpedMarker, transform, new Size(w, h));
  return unWarpedMarker;
}

void keyPressed() {
   
  if ((key == 'c') || (key == 'C')) status = 0;
  else if ((key == 'i') || (key == 'I')) status = 1;
  else if ((key == 'g') || (key == 'G')) status = 2;
  else if ((status == 0) && ((key == 'l') || (key == 'L'))) warpCam.loadSettings();
  else if ((status == 0) && ((key == 's') || (key == 'S'))) {
    println("salvado");
    warpCam.saveSettings();
  }
  else if ((key == 'k') && (players.size() > 0)) players.get(0).dead();
  
}

void mouseMoved() {
  
  if (status == 0) {
    for (int i = 0; i < 4; i++) {
    
      if (warpCam.getDistance(i) < warpCam.radius) warpCam.lock(i);
      else warpCam.unlock(i);
    
    }
  }
  
} 

void mouseDragged() {

  if (status == 0) {
    for (int i = 0; i < 4; i++) {
    
      if (warpCam.lockedPoints[i]) warpCam.update(i);
    
    }
  }
  
  else if (status == 2) {
  
    predator.posicion = new PVector(mouseX-260, mouseY-40);
    
  }
  
}

void controlEvent(ControlEvent theEvent) {
  if(theEvent.isFrom(mode)) {
    
    status = int(theEvent.getGroup().getValue());
    
    if (status == 0) {
    
      load.setVisible(true);
      save.setVisible(true);
    
    }
    
    else if (status == 2) {

      load.setVisible(false);
      save.setVisible(false);
      
    }
  }

}

// function colorA will receive changes from 
// controller with name colorA
public void load_Config(int theValue) {
  println("a button event from load: "+theValue);
  warpCam.loadSettings();
}

public void save_Config(int theValue) {
  println("a button event from save: "+theValue);
  warpCam.saveSettings();
}