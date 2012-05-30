import processing.serial.*;
int SerialPortNumber=2;
int PortSelected=2;

/*   =================================================================================       
 Global variables
 =================================================================================*/

int xValue, yValue, Command; 
boolean Error=true;

boolean UpdateGraph=true;
int lineGraph; 
int ErrorCounter=0;
int TotalRecieved=0; 

/*   =================================================================================       
 Local variables
 =================================================================================*/
boolean DataRecieved1=false, DataRecieved2=false, DataRecieved3=false;

float[] DynamicArrayTime1, DynamicArrayTime2, DynamicArrayTime3;
float[] Time1, Time2, Time3; 
float[] Voltage1, Voltage2, Voltage3;
float[] current;
float[] DynamicArray1, DynamicArray2, DynamicArray3;

float[] PowerArray= new float[0];            // Dynamic arrays that will use the append()
float[] DynamicArrayPower = new float[0];    // function to add values
float[] DynamicArrayTime= new float[0];

String portName; 
String[] ArrayOfPorts=new String[SerialPortNumber]; 

boolean DataRecieved=false, Data1Recieved=false, Data2Recieved=false;
int incrament=0;

int NumOfSerialBytes=8;                              // The size of the buffer array
int[] serialInArray = new int[NumOfSerialBytes];     // Buffer array
int serialCount = 0;                                 // A count of how many bytes received
int xMSB, xLSB, yMSB, yLSB;		                // Bytes of data

Serial myPort;                                        // The serial port object


/*   =================================================================================       
 A once off serail port setup function. In this case the selection of the speed,
 the serial port and clearing the serial port buffer  
 =================================================================================*/

void SerialPortSetup() {

  //  text(Serial.list().length,200,200);

  portName= Serial.list()[PortSelected];
  //  println( Serial.list());
  ArrayOfPorts=Serial.list();
  println(ArrayOfPorts);
  myPort = new Serial(this, portName, 115200);
  delay(50);
  myPort.clear(); 
  myPort.buffer(20);
}

/* ============================================================    
 serialEvent will be called when something is sent to the 
 serial port being used. 
 ============================================================   */

void serialEvent(Serial myPort) {

  while (myPort.available ()>0)
  {
    /* ============================================================    
     Read the next byte that's waiting in the buffer. 
     ============================================================   */

    int inByte = myPort.read();

    if (inByte==0)serialCount=0;

    if (inByte>255) {
      println(" inByte = "+inByte);    
      exit();
    }

    // Add the latest byte from the serial port to array:

    serialInArray[serialCount] = inByte;
    serialCount++;

    Error=true;
    if (serialCount >= NumOfSerialBytes ) {
      serialCount = 0;

      TotalRecieved++;

      int Checksum=0;

      //    Checksum = (Command + yMSB + yLSB + xMSB + xLSB + zeroByte)%255;
      for (int x=0; x<serialInArray.length-1; x++) {
        Checksum=Checksum+serialInArray[x];
      }

      Checksum=Checksum%255;



      if (Checksum==serialInArray[serialInArray.length-1]) {
        Error = false;
        DataRecieved=true;
      }
      else {
        Error = true;
        //  println("Error:  "+ ErrorCounter +" / "+ TotalRecieved+" : "+float(ErrorCounter/TotalRecieved)*100+"%");
        DataRecieved=false;
        ErrorCounter++;
        println("Error:  "+ ErrorCounter +" / "+ TotalRecieved+" : "+float(ErrorCounter/TotalRecieved)*100+"%");
      }
    }

    if (!Error) {


      int zeroByte = serialInArray[6];
      // println (zeroByte & 2);

      xLSB = serialInArray[3];
      if ( (zeroByte & 1) == 1) xLSB=0;
      xMSB = serialInArray[2];      
      if ( (zeroByte & 2) == 2) xMSB=0;

      yLSB = serialInArray[5];
      if ( (zeroByte & 4) == 4) yLSB=0;

      yMSB = serialInArray[4];
      if ( (zeroByte & 8) == 8) yMSB=0;


      //   println( "0\tCommand\tyMSB\tyLSB\txMSB\txLSB\tzeroByte\tsChecksum"); 
      //  println(serialInArray[0]+"\t"+Command +"\t"+ yMSB +"\t"+ yLSB +"\t"+ xMSB +"\t"+ xLSB+"\t" +zeroByte+"\t"+ serialInArray[7]); 

      // >=====< combine bytes to form large integers >==================< //

      Command  = serialInArray[1];

      xValue   = xMSB << 8 | xLSB;                    // Get xValue from yMSB & yLSB  
      yValue   = yMSB << 8 | yLSB;                    // Get yValue from xMSB & xLSB

        // println(Command+ "  "+xValue+"  "+ yValue+" " );

      /*
How that works: if xMSB = 10001001   and xLSB = 0100 0011 
       xMSB << 8 = 10001001 00000000    (shift xMSB left by 8 bits)                       
       xLSB =          01000011    
       xLSB | xMSB = 10001001 01000011    combine the 2 bytes using the logic or |
       xValue = 10001001 01000011     now xValue is a 2 byte number 0 -> 65536  
       */







      /*  ==================================================================
       Command, xValue & yValue have now been recieved from the chip
       ==================================================================  */

      switch(Command) {


        /*  ==================================================================
         Recieve array1 and array2 from chip, update oscilloscope      
         ==================================================================  */

      case 1: // Data is added to dynamic arrays
        DynamicArrayTime3=append( DynamicArrayTime3, (xValue) );
        DynamicArray3=append( DynamicArray3, (yValue) );

        break;

      case 2: // An array of unknown size is about to be recieved, empty storage arrays
        DynamicArrayTime3= new float[0]; 
        DynamicArray3= new float[0]; 
        break;    

      case 3:  // Array has finnished being recieved, update arrays being drawn 
        Time3=DynamicArrayTime3;
        Voltage3=DynamicArray3;
     //   println(Voltage3.length);
        DataRecieved3=true;
        break;  

        /*  ==================================================================
         Recieve array2 and array3 from chip
         ==================================================================  */


      case 4: // Data is added to dynamic arrays
        DynamicArrayTime2=append( DynamicArrayTime2, xValue );
        DynamicArray2=append( DynamicArray2, (yValue-16000.0)/32000.0*20.0  );
        break;

      case 5: // An array of unknown size is about to be recieved, empty storage arrays
        DynamicArrayTime2= new float[0]; 
        DynamicArray2= new float[0]; 
        break;    

      case 6:  // Array has finnished being recieved, update arrays being drawn 
        Time2=DynamicArrayTime2;
        current=DynamicArray2;
        DataRecieved2=true;
        break;  

        /*  ==================================================================
         Recieve a value of calculated power consumption & add it to the 
         PowerArray.
         ==================================================================  */
      case 20:  
        PowerArray=append( PowerArray, yValue );

        break; 

      case 21:  
        DynamicArrayTime=append( DynamicArrayTime, xValue ); 
        DynamicArrayPower=append( DynamicArrayPower, yValue );



        break;
      }
    }
  }
  redraw();  
  //    }
}


