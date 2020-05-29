#include <Servo.h>

//Variables para datos seriales
char canalVertical=0;
char canalHorizontal=1;
char serialData=0;

//Definición de servos
Servo servoVertical, servoHorizontal;

void setup(){

  //Asignar pin a los servos
  servoVertical.attach(2); 
  servoHorizontal.attach(3);
  
  //Posición inicial de cada servo
  servoVertical.write(90);
  servoHorizontal.write(90);

  //Iniciar la conexión serial
  Serial.begin(57600);
}

void loop(){

  //Mintras el Serial no envie datos esperamos
  while(Serial.available() <=0);

  //Leer el dato del Serial
  serialData = Serial.read();

  //Comprobamos a que servo se envia el dato desde el Serial
  if(serialData == canalVertical){
    
    //Espera el segundo byte del Serial, primero identifica segundo envia posición
    while(Serial.available() <=0);
    
    //Actualizamos la posición del servo
    servoVertical.write(Serial.read());
  }
  else if(serialData == canalHorizontal){
    while(Serial.available() <= 0);
    servoHorizontal.write(Serial.read());
  }
}
