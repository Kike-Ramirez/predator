import gab.opencv.*;
import processing.video.*;
import org.opencv.imgproc.Imgproc;
import org.opencv.core.MatOfPoint2f;
import org.opencv.core.Point;
import org.opencv.core.Size;

import org.opencv.core.Mat;
import org.opencv.core.CvType;
import java.awt.*;


// Capture video;
Movie video;

OpenCV opencv;
PImage warpedImage;
WarpCam warpCam;
Predator predator;
ArrayList<Player> players;

// Status: 0 => Calibration; 1 => Instructions; 2 => Game 
int status = 0;

void setup() {
  size(640, 480);
  // video = new Capture(this, 640, 480);
  video = new Movie(this, "medialabCCTV.mpg");
  
  opencv = new OpenCV(this, 640, 480);
  
  warpCam = new WarpCam();
  predator = new Predator();
  
  opencv.startBackgroundSubtraction(5, 3, 0.5);
  
  video.loop();
  
  warpedImage = createImage(640, 480, ARGB);  
  players = new ArrayList<Player>();
  
}

void draw() {
  
  
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
        
        if (dist < 10000) {
        
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
    
    
    predator.update();
    predator.display();
    
  }

  text(frameRate, 20, 20);
  text(players.size(), 20, 50);
  
}

//void captureEvent(Capture c) {
//  c.read();
//}

void movieEvent(Movie m) {
  m.read();
}


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
  
    predator.setTarget(new PVector(mouseX, mouseY));
    
  }
  
}