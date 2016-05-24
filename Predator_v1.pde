import gab.opencv.*;
import processing.video.*;
import org.opencv.imgproc.Imgproc;
import org.opencv.core.MatOfPoint2f;
import org.opencv.core.Point;
import org.opencv.core.Size;

import org.opencv.core.Mat;
import org.opencv.core.CvType;

Capture video;
OpenCV opencv;
PImage warpedImage;
WarpCam warpCam;

// Status: 0 => Calibration; 1 => Instructions; 2 => Game 
int status = 0;

void setup() {
  size(640, 480);
  video = new Capture(this, 640, 480);
  opencv = new OpenCV(this, 640, 480);
  
  warpCam = new WarpCam();
  
  opencv.startBackgroundSubtraction(5, 3, 0.5);
  
  video.start();
  
  warpedImage = createImage(640, 480, ARGB);  
  
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
    
    opencv.updateBackground();
    
    opencv.dilate();
    opencv.erode();
  
    noFill();
    stroke(255, 0, 0);
    strokeWeight(3);
    for (Contour contour : opencv.findContours()) {
      contour.draw();
    }
  }

  
}

void captureEvent(Capture c) {
  c.read();
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
  
}