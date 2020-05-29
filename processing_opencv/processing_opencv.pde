//================================================================================================
// FACE TRAKING CON OPEN CV
// Proyecto de Diseño de Interacción basado en la librería OpenCV y conexión serial entre Arduino 
// y Processing que consiste en una  aplicación de dos brazos motorizados que realizan el seguimiento 
// de una cara (Face Traking) basado en los ejemplos de http://ubaa.net/shared/processing/opencv/ y
// del articulo de Ryan Owens en SparKFun https://www.sparkfun.com/tutorials/304
//
// Fecha: 29/05/2020
//================================================================================================

import processing.serial.*;
import gab.opencv.*;
import processing.video.*;
import java.awt.*;

//================================================================================================
//Creación de variables
//================================================================================================


OpenCV opencv;
Capture video;

Rectangle[] caras;
Serial puertoSerial; 

int anchoCanvas = 320;
int altoCanvas = 240;

int valorConstraste   = 0;
int valorBrillo  = 0;

//Posición inicial de los servos
char posicionServoVertical = 90;
char posicionServoHorizontal = 90;

//Identificación canales Serial
char canalServoVertical = 0;
char canalServoHorizontal = 1;

//Coordenadas centrale de la cara detectada
int centroCaraVertical=0;
int centroCaraHorizontal=0;

//Coordenadas para calcular la mitad de la pantalla
//El programa busca igualar las coordenadas de la cara con estas
//Margen de error aceptable para ajustar ambas
int centroPantallaVertical = (240/2);
int centroPantallaHorizontal = (320/2);
int margenErrorPantalla = 15; 

//Cantidad de grados que se moverá el servo en cada actualización de posición
int gradosActualizacion=1;


//================================================================================================
//Función SETUP con la configuración inicial
//================================================================================================
void setup() {
  
  //Configuración tamaño pantalla
  size( 320, 240 );
  
  //Creación de objeto OpenCV con el tamaño de la pantalla
  opencv = new OpenCV(this, 320, 240);
  opencv.loadCascade( OpenCV.CASCADE_FRONTALFACE);
  
  //Creación e inicialización del objeto video
  video = new Capture (this, 320, 240);
  video.start();            
  
 
  //Asignar el primer puerto COM y configuración de baudios para la conexión
  puertoSerial = new Serial(this, Serial.list()[0], 57600); 

  //Imprimir mensajes al usuario
  println( "Arrastra con el ratón horizontalmente para cambiar el contraste" );
  println( "Arrastra con el ratón verticalmente para cambiar el brillo" );
  
  //Primer envio Serial con la configuración de los canales para cada servo y la posición inicial
  puertoSerial.write(canalServoVertical);
  puertoSerial.write(posicionServoVertical);
  puertoSerial.write(canalServoHorizontal);
  puertoSerial.write(posicionServoHorizontal);
}


//================================================================================================
//Función DRAW con el cuerpo de las funcionalidades
//================================================================================================
void draw() {
  
  //Esperamos a que la camara estea disponible
  if(video.available()==true){
    
    //Comenzamos a leer los valores de la camara y le aplicamos un filtro de escala de grises
    //para minimizar la información que se necesita procesar
    video.read();
    video.filter( GRAY );
    
    //Aplicamos los valores de brillo y contraste iniciales
    opencv.contrast( valorConstraste);
    opencv.brightness( valorBrillo );

  }
  
   //Mientras el video no se vea se espera 10 segundos
   while(video.height == 0) delay(10);
    
    //Se crea una imagen de 0x0 pixeles para pasar a opencv
    image(video, 0 ,0);
    
    //opencv carga la imagen vacia y comienza con la detecciónde la cara
    opencv.loadImage(video);
    caras = opencv.detect();
    

    
    //Si el array de fotogramas tiene contenido
    if(caras != null){
      
      //Por cada fotograma dibujamos un rectangulo rojo desde la esquina 
      //superior izquierda se calcula el centro
      for(int i = 0; i < caras.length; i++){
        strokeWeight(2);
        stroke(255,0,0);
        noFill();
        rect(caras[i].x, caras[i].y, caras[i].width, caras[i].height);
        
        String cadena =  "X" + centroCaraHorizontal + "Y" +centroCaraVertical;
        text(cadena, 10, 20);
        
      }
      
    //Comprobamos si se detectaron caras
    if(caras.length > 0){
      //Si se encuentra una cara buscamos el punto medio de la misma desde la esquina superior
      //izquierda como eje de coordenadas inicial (0,0)
      centroCaraVertical = caras[0].y + (caras[0].height/2);
      centroCaraHorizontal = caras[0].x + (caras[0].width/2);
      
      //EJE Y - VERTICAL
      //Comprobamos en el eje vertical, si el punto central de la cara se encuentra por
      //encima del punto central de la pantalla y si es así activamos el servo para corregir la posición.
      if(centroCaraVertical < (centroPantallaVertical - margenErrorPantalla)){
        //Si esta por debajo de la mitad movemos el servo
        if(posicionServoVertical >= 5)posicionServoVertical += gradosActualizacion;
      }
      //Si no comprobamos en el eje vertical, si el punto central de la cara se encuentra por
      //debajo del punto central de la pantalla y si es así activamos el servo para corregir la posición.     
      else if(centroCaraVertical > (centroPantallaVertical + margenErrorPantalla)){
        if(posicionServoVertical <= 175)posicionServoVertical -= gradosActualizacion;
      }
      
      //EJE X - HORIZONTAL
      //Comprobamos en el eje horizontal, si el punto central de la cara se encuentra hacia la derecha
      //del punto central de la pantalla y si es así activamos el servo para corregir la posición.
      if(centroCaraHorizontal < (centroPantallaHorizontal - margenErrorPantalla)){
        if(posicionServoHorizontal >= 5)posicionServoHorizontal += gradosActualizacion; //Update the pan position variable to move the servo to the left.
      }
      //Si no comprobamos en el eje horizontal, si el punto central de la cara se encuentra hacia la izquierda
      //del punto central de la pantalla y si es así activamos el servo para corregir la posición.
      else if(centroCaraHorizontal > (centroPantallaHorizontal + margenErrorPantalla)){
        if(posicionServoHorizontal <= 175)posicionServoHorizontal -= gradosActualizacion; //Update the pan position variable to move the servo to the right.
      }
      
    }
    
    
    //Enviar a través del Serial los nombres (claves) de cada servo y los nuevos valores de posición.
    puertoSerial.write(canalServoVertical);
    puertoSerial.write(posicionServoVertical);
    puertoSerial.write(canalServoHorizontal);
    puertoSerial.write(posicionServoHorizontal);
    
    //Esperamos por cada envio
    delay(1);
    }
 
}


//================================================================================================
//Función STOP para parar el video y el programa
//================================================================================================
public void stop() {
  video.stop();
  super.stop();
}



//================================================================================================
//Función MOUSEDRAGGED para cambiar brillo y contraste al arrastras el raton por la patanlla
//================================================================================================
void mouseDragged() {
  valorConstraste  = (int) map( mouseX, 0, anchoCanvas, -128, 128 );
  valorBrillo = (int) map( mouseY, 0, anchoCanvas, -128, 128 );
}
