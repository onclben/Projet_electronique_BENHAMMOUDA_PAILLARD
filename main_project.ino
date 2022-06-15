#include <Wire.h>

//acceleromètre-compas
#include "LSM303.h"
//initialisation objet classe
LSM303 compass;

//altimètre
#include "LPS.h"
//initialisation objet classe
LPS ps;

//gyroscope
#include "L3G.h"
//initialisation objet classe
L3G gyro;

//pour afficher les datas
char data_to_send[100];

void setup() {
  
  // put your setup code here, to run once:
  Serial.begin(9600);
  Wire.begin();

  //détection gyroscope
  if (!gyro.init()){
    Serial.println("Failed to autodetect gyrometre!");
    while (1);
    }
  gyro.enableDefault();

  //détection altimètre
  if (!ps.init()){
    Serial.println("Failed to autodetect gyro altimeter!");
    while (1);
    }
  ps.enableDefault();

  //détection acceléromètre/magnétomètre
  if (!compass.init()){
    Serial.println("Failed to autodetect gyro compass!");
    while(1);
    }
  compass.enableDefault();  

}
//comment
void loop() {
  // put your main code here, to run repeatedly
    
  gyro.read();
  float gx = gyro.g.x / 267.4938776;
  float gy = gyro.g.y / 267.4938776;
  float gz = gyro.g.z / 267.4938776;
   
  ////////////////////////////////////////////////////////////////////////////////

  compass.read();
  //valeur accéléromètre
  float ax= compass.a.x/15000.0;
  float ay= compass.a.y/15000.0;
  float az= compass.a.z/15000.0;
  int heading = atan2(compass.m.y, compass.m.x) * 180 / M_PI;

  ////////////////////////////////////////////////////////////////////////////////
  
  float pressure = ps.readPressureMillibars();
  float altitude = ps.pressureToAltitudeMeters(pressure);
  float temperature = ps.readTemperatureC();

 
  ////////////////////////////////////////////////////////////////////////////////

  //on ajoute toutes les valeurs et on les écrit sur le port COM pour bien les récupérer
  //Gyrometre -- Accelerometre -- Altimetre
  snprintf(data_to_send, sizeof(data_to_send),"%f,%f,%f,%f,%f,%f,%d,%f,%f,%f",gx,gy,gz,ax,ay,az,heading,altitude,temperature,pressure);

  Serial.print(data_to_send);
  Serial.print("\n");
  delay(500); // on attend 500ms avant de redemander de nouvelles données
  
}
