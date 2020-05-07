// This code must be run using the Processing IDE. 
// It must be run simultaneously with the .ino code using the Energia IDE

import P5ireBase.library.*; // This library needs to be downloaded separately
import processing.serial.*; // This library needs to be

Serial energiaSerial; // create local serial object from serial library
P5ireBase fireTimeData; // firebase object - for time data
P5ireBase fireAppData; // for app data
P5ireBase fireArrivalData; // for recording actual arrival time

String serialData = null; // var to collect serial data
int newline = 10; // acsii code for carriage return in serial
float serialNum; // float for storing converted ascii serial data
int totalNum; // storing time data 
float avgTime = 15*60; // storing average time for person in line
int arrivalTime; // storing time of day each person joins line

void resetter(P5ireBase fireTime, P5ireBase fireApp, P5ireBase fireArrival)
{
  for (int i = 1; i <= 100; i++) 
  {
    fireTime.setValue(Integer.toString(i), "0"); // update firebase 
    fireArrival.setValue(Integer.toString(i), "0");  
  } // loop from 1 to max size for time data (check .ino file for max time)
  
  totalNum = 0; // default number of people inLine
  avgTime = 60*15; // default average time
  fireApp.setValue("AvgTime", Integer.toString(int(avgTime)));
  fireApp.setValue("NumInLine", Integer.toString(totalNum));
  
} // reset everything

void setup()
{
  size(200, 400);  
  
  //link processing to serial port (correct one)
  String energiaPort = Serial.list() [2]; // find correct serial port (3rd one for me)
  energiaSerial = new Serial(this, energiaPort, 9600);
  
  // initialize firebase
  fireTimeData = new P5ireBase(this, "https://inlinesensor.firebaseio.com/duration");// time spent 
  fireAppData = new P5ireBase(this, "https://inline-c2e5b.firebaseio.com/"); // app updating
  fireArrivalData = new P5ireBase(this, "https://inlinesensor.firebaseio.com/arrival");// time arrived
  
  resetter(fireTimeData, fireAppData, fireArrivalData); // reset all firebase data
  
} // void setup

void draw()
{
  while (energiaSerial.available() > 0)
  {
    serialData = energiaSerial.readStringUntil(newline); // STRIPs data of serial port
    
    if (serialData != null)
    {
      background(0); // turns black when data is available to serial monitor 
      serialNum = float(serialData); // takes data from serial and turns into number
      println(int(serialNum));
      
      if (serialNum == -1)
      {
        resetter(fireTimeData, fireAppData, fireArrivalData); // reset all firebase data
      } // reset
      else if (serialNum < 1000)
      {
        fireAppData.setValue("NumInLine", Integer.toString(int(serialNum))); // update firebase 
      } // update inLine value
      else if (serialNum >= 1000)
      {
        totalNum++;
        serialNum /= 1000;
        // println("TotalNum:", totalNum);
        int realTime = (3600 * hour() + 60 * minute() + second());
        println("Time", realTime);
        arrivalTime = realTime - int(serialNum);
        
        fireTimeData.setValue(Integer.toString(totalNum), Float.toString(serialNum)); // update firebase 
        fireArrivalData.setValue(Integer.toString(totalNum), Integer.toString(arrivalTime)); // update firebase 
        
        if (totalNum <= 1)
        {
          avgTime = serialNum;
        } // if only one person is in line
        else 
        {
          avgTime = ((avgTime * (totalNum - 1)) + int(serialNum)) / totalNum; // actual average
        } // if more than one person is in line
        
        fireAppData.setValue("AvgTime", Float.toString(avgTime)); // update firebase 
        
      } // update time data
    } // data was on serial port
    
  } // while - do something if there is data on port
    
} // void loop
