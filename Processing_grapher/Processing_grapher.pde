   Graph MyArduinoGraph = new Graph(150, 80,500,300,color (200,20,20));

   void setup() {

      size(800, 500); 
   
      MyArduinoGraph.xLabel="Readnumber";
      MyArduinoGraph.yLabel="Amp";
      MyArduinoGraph.Title=" Capacitative sense graph";  
      noLoop();
      PortSelected=0;      /* ====================================================================
                              adjust this (0,1,2...) until the correct port is selected 
                              In my case 2 for COM4, after I look at the Serial.list() string 
                              println( Serial.list() );
                              [0] "COM1"  
                              [1] "COM2" 
                              [2] "COM4"
                             ==================================================================== */
      SerialPortSetup();      // speed of 115200 bps etc.
  }


    void draw() {
      
      background(255);
   
   /* ====================================================================
       Time3 & Voltage3 are arrays sent by the chip (any size)look in the
       switch(Command) statement if you're interested.
       DataRecieved3 is made true when the chip confirms that the 
       array has finished being sent
      ====================================================================  */
   
   if( DataRecieved3 ){
                                    
      MyArduinoGraph.yMax=1000;      
      MyArduinoGraph.yMin=-200;      
      MyArduinoGraph.xMax=int (max(Time3));
      MyArduinoGraph.DrawAxis();    
      MyArduinoGraph.smoothLine(Time3,Voltage3);
   //   MyArduinoGraph.smoothLine(Time2,current);
   }
      
    }
