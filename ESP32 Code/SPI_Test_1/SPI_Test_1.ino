#include <SPI.h>

// Based on code https://microcontrollerslab.com/esp32-spi-communication-tutorial-arduino/

  #define HSPI_MISO   MISO
  #define HSPI_MOSI   MOSI
  #define HSPI_SCLK   SCK
  #define HSPI_SS     SS
  int System_Ready = 17;
  int Start = 34;
  int Ready = 0;
  uint16_t data = 0b0; //initialize data
  uint16_t TXdata = 0b0; // initialize transmit data to 0
  uint16_t RXdata = 0b0;  //initialize recieved data

static const int spiClk = 10000000; // 10 MHz

//uninitalised pointers to SPI objects
SPIClass * hspi = NULL;

void setup() {
 Serial.begin(115200);
  // Initialise GPIO Pins
  digitalWrite (System_Ready, LOW);
  pinMode(System_Ready, OUTPUT);
  pinMode(Start, INPUT);

  //initialise instance of the SPIClass attached to HSPI
  hspi = new SPIClass(HSPI);
  
  //clock miso mosi ss
  //alternatively route through GPIO pins
  hspi->begin(HSPI_SCLK, HSPI_MISO, HSPI_MOSI, HSPI_SS); //SCLK, MISO, MOSI, SS

  //set up slave select pins as outputs as the Arduino API
  //doesn't handle automatically pulling SS low
  pinMode(HSPI_SS, OUTPUT); //HSPI SS
}

// the loop function runs over and over again until power down or reset
void loop() {
  Ready = digitalRead (Start);

  if (Ready) {
      delay(1000);
      digitalWrite (System_Ready, HIGH);
  } else {digitalWrite (System_Ready, LOW); }
  TXdata = 0x0;
  Serial.println (Ready);
  Serial.print ("Output to Nano ");
  Serial.println(TXdata, HEX);
  hspi_send_command();
  Serial.print ("input from Nano ");
  Serial.println(RXdata, HEX);
  Serial.println ();
  //delay(100);
}

void hspi_send_command() {
  
  hspi->beginTransaction(SPISettings(spiClk, MSBFIRST, SPI_MODE0));
  data = TXdata;
  digitalWrite(HSPI_SS, LOW);
  RXdata = hspi->transfer16(data);
  digitalWrite(HSPI_SS, HIGH);
  hspi->endTransaction();
  delay(100);

}