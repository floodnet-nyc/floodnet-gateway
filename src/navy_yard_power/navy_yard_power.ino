#include "LoRaWan_APP.h"
#include "Arduino.h"
#include <Wire.h>
#include <INA3221.h>

// Set I2C address to 0x40 (A0 pin -> GND)
INA3221 ina_0(INA3221_ADDR40_GND);

/*
   set LoraWan_RGB to Active,the RGB active in loraWan
   RGB red means sending;
   RGB purple means joined done;
   RGB blue means RxWindow1;
   RGB yellow means RxWindow2;
   RGB green means received done;
*/

/* OTAA para*/
uint8_t devEui[] = {  };
uint8_t appEui[] = {  };
uint8_t appKey[] = {  };

/* ABP para*/
uint8_t nwkSKey[] = {  };
uint8_t appSKey[] = {  };
uint32_t devAddr =  ( uint32_t )0x260cb35a;

/*LoraWan channelsmask, default channels 0-7*/
uint16_t userChannelsMask[6] = { 0xFF00, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000 };

/*LoraWan region, select in arduino IDE tools*/
LoRaMacRegion_t loraWanRegion = ACTIVE_REGION;

/*LoraWan Class, Class A and Class C are supported*/
DeviceClass_t  loraWanClass = LORAWAN_CLASS;

/*the application data transmission duty cycle.  value in [ms].*/
uint32_t appTxDutyCycle = 60000;

/*OTAA or ABP*/
bool overTheAirActivation = LORAWAN_NETMODE;

/*ADR enable*/
bool loraWanAdr = LORAWAN_ADR;

/* set LORAWAN_Net_Reserve ON, the node could save the network info to flash, when node reset not need to join again */
bool keepNet = LORAWAN_NET_RESERVE;

/* Indicates if the node is sending confirmed or unconfirmed messages */
bool isTxConfirmed = LORAWAN_UPLINKMODE;

/* Application port */
uint8_t appPort = 2;
/*!
  Number of trials to transmit the frame, if the LoRaMAC layer did not
  receive an acknowledgment. The MAC performs a datarate adaptation,
  according to the LoRaWAN Specification V1.0.2, chapter 18.4, according
  to the following table:

  Transmission nb | Data Rate
  ----------------|-----------
  1 (first)       | DR
  2               | DR
  3               | max(DR-1,0)
  4               | max(DR-1,0)
  5               | max(DR-2,0)
  6               | max(DR-2,0)
  7               | max(DR-3,0)
  8               | max(DR-3,0)

  Note, that if NbTrials is set to 1 or 2, the MAC will not decrease
  the datarate, in case the LoRaMAC layer did not receive an acknowledgment
*/
uint8_t confirmedNbTrials = 4;

/* Prepares the payload of the frame */
static void prepareTxFrame( uint8_t port )
{
  /*appData size is LORAWAN_APP_DATA_MAX_SIZE which is defined in "commissioning.h".
    appDataSize max value is LORAWAN_APP_DATA_MAX_SIZE.
    if enabled AT, don't modify LORAWAN_APP_DATA_MAX_SIZE, it may cause system hanging or failure.
    if disabled AT, LORAWAN_APP_DATA_MAX_SIZE can be modified, the max value is reference to lorawan region and SF.
    for example, if use REGION_CN470,
    the max value for different DR can be found in MaxPayloadOfDatarateCN470 refer to DataratesCN470 and BandwidthsCN470 in "RegionCN470.h".
  */
  uint16_t batLevel;
  uint16_t curLevel;
  byte lowcur, highcur, lowbat, highbat;

  batLevel = ina_0.getVoltage(INA3221_CH1) * 1000;
  curLevel = ina_0.getCurrent(INA3221_CH1) * -1000;

  Serial.print(batLevel);
  Serial.println(" mV");
  Serial.print(curLevel);
  Serial.println(" mA");
  Serial.println();

  lowbat = lowByte(batLevel);
  highbat = highByte(batLevel);

  lowcur = lowByte(curLevel);
  highcur = highByte(curLevel);

  appDataSize = 4;

  appData[0] = (unsigned char)lowbat;
  appData[1] = (unsigned char)highbat;

  appData[2] = (unsigned char)lowcur;
  appData[3] = (unsigned char)highcur;
}

void current_measure_init() {
  ina_0.begin(&Wire);
  ina_0.reset();
  // Set shunt resistors to 100 mOhm for all channels
  ina_0.setShuntRes(100, 100, 100);
  ina_0.setAveragingMode(INA3221_REG_CONF_AVG_1024);
  ina_0.setBusConversionTime(INA3221_REG_CONF_CT_8244US);
  ina_0.setShuntConversionTime(INA3221_REG_CONF_CT_8244US);
}

void setup() {
  Serial.begin(115200);
  pinMode(GPIO0, INPUT);
  pinMode(GPIO4, INPUT);
  pinMode(GPIO5, INPUT);
  pinMode(Vext, OUTPUT);

  digitalWrite(Vext, LOW);   //power line to INNA3221 ON
  delay(1000);

  Serial.println("About to init INA3221...");
  current_measure_init();
  Serial.println("INA3221 init successful");
  Serial.println();
  while (!Serial) {
    delay(1);
  }
#if(AT_SUPPORT)
  enableAt();
#endif
  deviceState = DEVICE_STATE_INIT;
  LoRaWAN.ifskipjoin();
}

void loop()
{
  switch ( deviceState )
  {
    case DEVICE_STATE_INIT:
      {
#if(LORAWAN_DEVEUI_AUTO)
        LoRaWAN.generateDeveuiByChipID();
#endif
#if(AT_SUPPORT)
        getDevParam();
#endif
        printDevParam();
        LoRaWAN.init(loraWanClass, loraWanRegion);
        deviceState = DEVICE_STATE_JOIN;
        break;
      }
    case DEVICE_STATE_JOIN:
      {
        digitalWrite(Vext, LOW);   //power line to INNA3221 ON
        delay(1000);
        LoRaWAN.join();
        break;
      }
    case DEVICE_STATE_SEND:
      {
        digitalWrite(Vext, LOW);   //power line to INNA3221 ON
        delay(3000);
        prepareTxFrame(appPort);
        LoRaWAN.send();
        deviceState = DEVICE_STATE_CYCLE;
        break;
      }
    case DEVICE_STATE_CYCLE:
      {
        // Schedule next packet transmission
        txDutyCycleTime = appTxDutyCycle + randr( 0, APP_TX_DUTYCYCLE_RND );
        LoRaWAN.cycle(txDutyCycleTime);
        deviceState = DEVICE_STATE_SLEEP;
        break;
      }
    case DEVICE_STATE_SLEEP:
      {
        LoRaWAN.sleep();
        break;
      }
    default:
      {
        deviceState = DEVICE_STATE_INIT;
        break;
      }
  }
}
