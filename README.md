# Line Tracking

This project uses sensors to keep track of the number of people in any line. 
It also collects data about the time each customer spends in the line at any store, and uses the data for basic statistical analysis. 
The code updates data to Google Firebase to update changes in real time. 

The physical sensors are modeled using the TI MSP432 Launchpad and MyParts Kit. 
The Energia IDE is used to upload the code to the MSP432 microcontroller (given in the .ino file). 
The Processing IDE is used to read data from the Energia serial monitor and upload the data to Google Firebase. 
MATLAB is used to read data from the Firebase realtime database, determine a basic predicted estimate using the time data of the previous customers in line, and write the data back to the Firebase database. 


