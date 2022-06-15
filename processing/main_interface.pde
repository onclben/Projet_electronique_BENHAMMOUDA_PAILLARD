//  Created by Nicolas PAILLARD & Mehdi BENHAMMOUDA on 04/2022.
//  Copyright © 2022 Nicolas PAILLARD & Mehdi BENHAMMOUDA. All rights reserved.

import processing.serial.*;

Serial myPort;
int valeurPortSerie;

//ligne de données reçues
String stringLecture;
String[] data_received = new String[10];

//répartition des données dans de variables explicites
float[] Gyro = new float[3];
float[] Accel = new float [3];
float Azimuth;
float[] Alti = new float [3];

//données utiles pour traitement
float Roll, Roll_prec;//Roulis : état précédent pour calcul état présent
float Pitch, Pitch_prec;//Tangage : état précédent pour calcul état présent
 

int W=1400; //My Laptop's screen width 
int H=800;  //My Laptop's screen height 
float SpanAngle=120;  //<>//
int NumberOfScaleMajorDivisions;  //<>//
int NumberOfScaleMinorDivisions; 
color earth_brown,sky_blue;


 //<>//
void setup() {
 
  //set window size
  size(1400, 800);
 
  
  // set window title
  surface.setTitle("INSTRUMENT DE BORD");
  
  // Liste des ports disponibles
  println(Serial.list());
  myPort = new Serial(this, Serial.list()[1], 9600); // à modifier en indiquant votre numéro de port série
  myPort.bufferUntil('\n');   // ne pas appeller serialEvent () sauf si un caractère de nouvelle ligne est présent dans le buffer
  
  //initialisation des valeurs nécessaire
  Pitch_prec = 0;
  Roll_prec = 0;
  
  earth_brown=color(160,82,45);
  sky_blue=color(0,150,255);  
  
}

void serialEvent(Serial myPort){ //Reading the datas by Processing.
  //on récupère les données envoyées et on les sépare grâce aux ","
  stringLecture = myPort.readStringUntil('\n'); // lire une chaine jusqu'au retour chariot
  data_received = stringLecture.split(",");

  //on place les données dans des variables explicites
  for (int i = 0; i < 3; i++) {
    Gyro[i] = Float.parseFloat(data_received[i]);
  }

  for (int i = 0; i < 3; i++) {
    Accel[i] = Float.parseFloat(data_received[i+3]);
  }

  Azimuth = Float.parseFloat(data_received[6]);

  for (int i = 0; i < 3; i++) {
    Alti[i] = Float.parseFloat(data_received[i+7]);
  }

  //pour simple vérification des données reçues
  print(stringLecture);

}

//fonction appelée en boucle pour redessiner l'interface avec les nouvelles acquisitions de valeurs
void draw() { 
  
  background(150,150,150); 
  translate(W/10, H/2);  //on déplace l'origine de notre interface

  //on déplace l'origine de notre interface pour dessiner la boussole et afficher l'azimuth
  translate(W/2, 0); 
  Compass(); 
  ShowAzimuth();
  
  //on affiche l'altitude la température et la pression
  ShowAltitude();
  ShowTemperature();
  ShowPressure();
  
  //on redéfinie le milieu de l'IHM pour mieux contrôler la ligne qui tourne
  translate(-1100,-450);
  //On calcule le roulis avant de pouvoir l'aficher et de le dessiner
  CalculRoll();
  DrawRoll();  
  ShowRoll();

  
  //on redéfinie le milieu de l'IHM pour mieux contrôler la ligne qui tourne
  translate(0,850);
  //On calcule le tangage avant de pouvoir l'aficher et de le dessiner
  CalculPitch();
  ShowPitch();
  DrawPitch();  
}

//Affiche l'azimuth dans un rectangle
void ShowAzimuth() 
{ 
  fill(50); 
  noStroke(); 
  rect(-240, 470, 600, 80);
  int Azimuth1=round(Azimuth); 
  textAlign(CORNER); 
  textSize(60); 
  fill(255); 
  text("Azimuth:  "+Azimuth1+" Deg", -200, 470, 700, 150);
  //textSize(40);
  //fill(25,25,150);
  //text("FLIGHT SIMULATOR", -350, 477, 500, 60); 
}

//dessine la boussole
void Compass() 
{ 
  scale(0.5); 
  noFill(); 
  stroke(100); 
  strokeWeight(80); 
  ellipse(0, 0, 750, 750); 
  strokeWeight(50); 
  stroke(50); 
  fill(0, 0, 40); 
  ellipse(0, 0, 610, 610); 
  for (int k=255;k>0;k=k-5) 
  { 
    noStroke(); 
    fill(0, 0, 255-k); 
    ellipse(0, 0, 2*k, 2*k); 
  } 
  strokeWeight(20); 
  NumberOfScaleMajorDivisions=18; 
  NumberOfScaleMinorDivisions=36;  
  SpanAngle=180; 
  CircularScale(); 
  rotate(PI); 
  SpanAngle=180; 
  CircularScale(); 
  rotate(-PI); 
  fill(255); 
  textSize(60); 
  textAlign(CENTER); 
  text("W", -420, -35, 100, 200); 
    text("E", 330, -35, 100, 80); 
  text("N", -45, -420, 100, 80); 
  text("S", -45, 350, 100, 80); 
  textSize(40); 
  text("COMPASS", -100, -130, 200, 80); 
  rotate(PI/4); 
  textSize(40); 
  text("NW", -370, 0, 100, 50); 
  text("SE", 365, 0, 100, 50); 
  text("NE", 0, -355, 100, 50); 
  text("SW", 0, 365, 100, 50); 
  rotate(-PI/4); 
  CompassPointer(); 
}

//dessine la flèche verte qui indique l'orientation du robot
void CompassPointer() 
{ 
  rotate(PI+radians(Azimuth));  
  stroke(0); 
  strokeWeight(4); 
  fill(100, 255, 100); 
  triangle(-20, -210, 20, -210, 0, 270); 
  triangle(-15, 210, 15, 210, 0, 270); 
  ellipse(0, 0, 45, 45);   
  fill(0, 0, 50); 
  noStroke(); 
  ellipse(0, 0, 10, 10); 
  triangle(-20, -213, 20, -213, 0, -190); 
  triangle(-15, -215, 15, -215, 0, -200); 
  rotate(-PI-radians(Azimuth)); 
}

void CircularScale() 
{ 
  float GaugeWidth=800;  
  textSize(GaugeWidth/30); 
  float StrokeWidth=1; 
  float an; 
  float DivxPhasorCloser; 
  float DivxPhasorDistal; 
  float DivyPhasorCloser; 
  float DivyPhasorDistal; 
  strokeWeight(2*StrokeWidth); 
  stroke(255);
  float DivCloserPhasorLenght=GaugeWidth/2-GaugeWidth/9-StrokeWidth; 
  float DivDistalPhasorLenght=GaugeWidth/2-GaugeWidth/7.5-StrokeWidth;
  for (int Division=0;Division<NumberOfScaleMinorDivisions+1;Division++) 
  { 
    an=SpanAngle/2+Division*SpanAngle/NumberOfScaleMinorDivisions;  
    DivxPhasorCloser=DivCloserPhasorLenght*cos(radians(an)); 
    DivxPhasorDistal=DivDistalPhasorLenght*cos(radians(an)); 
    DivyPhasorCloser=DivCloserPhasorLenght*sin(radians(an)); 
    DivyPhasorDistal=DivDistalPhasorLenght*sin(radians(an));   
    line(DivxPhasorCloser, DivyPhasorCloser, DivxPhasorDistal, DivyPhasorDistal); 
  }
  DivCloserPhasorLenght=GaugeWidth/2-GaugeWidth/10-StrokeWidth; 
  DivDistalPhasorLenght=GaugeWidth/2-GaugeWidth/7.4-StrokeWidth;
  for (int Division=0;Division<NumberOfScaleMajorDivisions+1;Division++) 
  { 
    an=SpanAngle/2+Division*SpanAngle/NumberOfScaleMajorDivisions;  
    DivxPhasorCloser=DivCloserPhasorLenght*cos(radians(an)); 
    DivxPhasorDistal=DivDistalPhasorLenght*cos(radians(an)); 
    DivyPhasorCloser=DivCloserPhasorLenght*sin(radians(an)); 
    DivyPhasorDistal=DivDistalPhasorLenght*sin(radians(an)); 
    if (Division==NumberOfScaleMajorDivisions/2|Division==0|Division==NumberOfScaleMajorDivisions) 
    { 
      strokeWeight(15); 
      stroke(0); 
      line(DivxPhasorCloser, DivyPhasorCloser, DivxPhasorDistal, DivyPhasorDistal); 
      strokeWeight(8); 
      stroke(100, 255, 100); 
      line(DivxPhasorCloser, DivyPhasorCloser, DivxPhasorDistal, DivyPhasorDistal); 
    } 
    else 
    { 
      strokeWeight(3); 
      stroke(255); 
      line(DivxPhasorCloser, DivyPhasorCloser, DivxPhasorDistal, DivyPhasorDistal); 
    } 
  } 
}

//Affiche l'altitude dans un rectangle
void ShowAltitude() 
{ 
  fill(50); 
  noStroke(); 
  rect(500, -600, 600, 80);
  int Altitude=round(Alti[0]); 
  textAlign(CORNER); 
  textSize(60); 
  fill(255); 
  text("Altitude:  "+Altitude+" m", 540, -600, 700, 150);
}

//Affiche la température dans un rectangle
void ShowTemperature() 
{ 
  fill(50); 
  noStroke(); 
  rect(500, -450, 600, 80);
  int Temperature=round(Alti[1]); 
  textAlign(CORNER); 
  textSize(60); 
  fill(255); 
  text("Température:  "+Temperature+" °C", 540, -450, 700, 150);
}

//Affiche la pression dans un rectangle
void ShowPressure() 
{ 
  fill(50); 
  noStroke(); 
  rect(500, -300, 600, 80);
  int Pressure=round(Alti[2]); 
  textAlign(CORNER); 
  textSize(60); 
  fill(255); 
  text("Pression:  "+Pressure+" mbar", 540, -300, 700, 150);
}

//Calcule du Roulis
void CalculRoll(){
  Roll = (Roll_prec + 0.500 * Gyro[0])%360;//roulis : rotations autour de l'axe x -- %360 car si 1 tour complet on revient à l'initiale
  Roll_prec = Roll;
}

//Calcule du Tangage
void CalculPitch(){
  Pitch = (Pitch_prec + 0.500 * Gyro[1])%360;//tangage : rotation autour de l'axe y -- -- %360 car si 1 tour complet on revient à l'initiale
  Pitch_prec = Pitch;
}

//Affiche le roulis dans un rectangle
void ShowRoll() 
{ 
  fill(50); 
  noStroke(); 
  rect(-300, 350, 600, 80);
  textAlign(CORNER); 
  textSize(60); 
  fill(255); 
  text("Roulis:  "+round(Roll)+" Deg", -260, 350, 700, 150);
}

//Affiche le tangage dans un rectangle
void ShowPitch() 
{ 
  fill(50); 
  noStroke(); 
  rect(-300, 250, 600, 80);
  textAlign(CORNER); 
  textSize(60); 
  fill(255); 
  text("Tangage:  "+round(Pitch)+" Deg", -260, 250, 700, 150);
}

//Dessine l'animation du roulis et tourne en fonction
void DrawRoll(){
  
  rotate(radians(Roll));

  fill(sky_blue);
  noStroke();
  arc(0,0,600,600,-PI,0);
  
  fill(earth_brown);
  noStroke();
  arc(0,0,600,600,0,PI);
  
  rotate(radians(-Roll));//on annule la rotation pour dessiner ce qui suit (sinon ça rotate tous les prochains éléments déssinés)
}

//Dessine l'animation du tangage et tourne en fonction
void DrawPitch(){

  //2 lignes de niveau blanches
  strokeWeight(16);
  stroke(255,255,255);
  line(-300,0,-200,0);
  
  strokeWeight(16);
  stroke(255,255,255);
  line(200,0,300,0);
  
  //lignes qui bouge en fonction du tangage de l'avion
  strokeWeight(16);
  stroke(255,0,0);
  rotate(radians(-Pitch));
  line(-200,0,200,0);  

  rotate(radians(Pitch));//on annule la rotation pour dessiner ce qui suit (sinon ça rotate tous les prochains éléments déssinés)
}
