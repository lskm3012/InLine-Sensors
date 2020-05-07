// This code is written for the TI MSP432 microcontroller
// This code must be run using the Energia IDE and must be connected with microcontroller and the physical construction of the circuit
// This code can also run with an arduino, but the pin numbers would have to be adjusted accordingly

// The code only accounts for one IR led sensor and two buttons to keep track of the number of people in line
// It can be modified to work only using two sensors, keeping track of people entering and exiting the line

const int enterSensor = 37; // digital read - enter sensor/button
const int exitSensor = 39; // digital read - exit sensor/button
const int resetButton = 35; // complete system reset
const int enterDetector = 12; // analog read pin
const int detectorThreshold = 550; // Threshold of mapped values from 0-1023
int inLine = 0; // number of people in line
int enterNum = 0; // number of people entering
int exitNum = 0; // number of people exiting
unsigned long timeData[100]; // for holding time data - max of 999

void resetter()
{
  inLine = 0; 
  enterNum = 0; 
  exitNum = 0; 
  Serial.println(-1);
  delay(500);
} // reset everything

void setup()
{
  Serial.begin(9600);
  pinMode(enterSensor, INPUT_PULLUP);
  pinMode(exitSensor, INPUT_PULLUP);
  pinMode(resetButton, INPUT_PULLUP);
  delay(500);
  Serial.println(inLine);
} // void setup

void loop()
{  

//  if (enterNum == 0)
//    Serial.println(inLine); // initial condition
  if (digitalRead(resetButton) == 0)
  {
    resetter();
  } // reset everything
  if(digitalRead(enterSensor) == 0 || analogRead(enterDetector) >= detectorThreshold)
  {
     inLine++;
     timeData[enterNum] = millis();
     enterNum++;
     Serial.println(inLine);
  } // increase inLine
  
  if(digitalRead(exitSensor) == 0)
  {
    if(inLine > 0)
    {
      inLine--;
      timeData[exitNum] = millis() - timeData[exitNum]; // update time data for each person

      if (timeData[exitNum] < 1000)
        timeData[exitNum] = 1000; // 1 second is the minimum value
                  
      Serial.println(timeData[exitNum]);
      exitNum++;
      Serial.println(inLine); // capture time of exit
    } // Cannot have less than 0 people in line
  } // decrease inLine
      
  //Serial.println("People in line: " + String(inLine));
  //Serial.println("Detector reading: " + String(analogRead(enterDetector)));

  // prevent overcounting one person
  while (digitalRead(enterSensor) == 0 || digitalRead(exitSensor) == 0 || analogRead(enterDetector) >= detectorThreshold)
  {
    if (digitalRead(resetButton) == 0)
    {
      resetter();
      break;
    } // reset everything
  }
  delay(500); 
} // void loop
