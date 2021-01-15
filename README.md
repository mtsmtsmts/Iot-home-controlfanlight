# Iot-home-controlfanlight
Using a NodeMCU with ESP8266, HTTP requests, IFTTT, and Google Assistant to control a ceiling fan and a LED light strip. MCU uses GPIO pins and a relay dev board to control the ceiling fan buttons on the remote's PCB. It is possible to recreate the transmitter circuit the remote uses, left for a future imp. Future plans include using NPN BJT transistors for the buttons and a FET for the light, I didn't have enough NPNs to complete the project so I used a relay board on hand, albeit temporarily... maybe.


### Features
  1. User can control all states of the ceiling fan on/off/high/med/low/light on/light off/light dim
  2. Commands are sent one of three methods: Google Assistant using IFTTT, a web HTTP request, manually with buttons 
  3. A webIDE allows the user to modify code OTA
  4. The light is controlled on/off using the above methods
  5. The light operates on a schedule referenced to the on-board 'software' RTC
  6. RTC is set using a NTP server

### GPIO
The NodeMCU GPIO pins are connected to the 8-channel active **high**, relay development board. Note: the relay boards are available in active high and more commonly in active low optocoupled configurations. This code is written for active high.

### Timing
Software timers are used to enable the remote buttons for ~2 seconds. The dimming state of the ceiling fan light can changed by enabling the button for a longer period

### Power Supply
A 12V adapter provides power to a project board which has a LM7805 and powers the relay board plus the 5V pin of the NodeMCU.


### HTTP Handling
Enabling the button 'presses' is controlled one of three ways: manually, using Google Assistant and IFTTT webhooks, or an HTTP GET request. A webIDE provides the ability to modify any of the functions OTA. Much code is credited to different authors and the NodeMCU documentation. The webIDE operates in parallel with the application code because of memory limitations. To load the webIDE a browser sends an http request with a key word, resets the esp8266, and starts the webIDE. The user is able to upload new files, edit files stored in flash, compile files, delete files, and restart the NodeMCU. The IDE will automatically exit after 10 minutes and return the esp8266 to application code, restoring the led strip light schedule. 

### Schematic




### How To Use
1. Flash firmware to ESP8266 using ESPEasy
2. Modify and flash program code using ESPlorer
3. Configure IFTTT webhooks using the reference in the resources below
4. Use Google Assistant or access using a web browser 


#### To access the application using web browser:
    
  ##### http://`IP_Address`:`Port`/`cmdString:` `Command`

- `IP_Address` = Use your LAN ip set by your router typical: 192.168.0.xx. Outside LAN use your IP address set by your ISP.

- `Port` = The server port (code is set to 8099)

- `cmdString` = Your keyword (default is "webhooks")

- `Command` = Your command. e.g. on the default configuration you can use "on", "off",etc...
 
#### To access the WebIDE using web browser:
  ##### http://`IP_Address`:`Port`/`Command`
 
 - `Command` = string set in code to enable webide (restart in this case). 
 
 LAN Example:
        
        192.168.0.13:8098/webhooks:Temp=on  or  192.168.0.13:8099/restart
        

# Resources
NodeMCU docs https://nodemcu.readthedocs.io/en/release/

A simple webIDE https://github.com/joysfera/nodemcu-web-ide 

IFTTT to ESP8266 https://github.com/limbo666/IFTTT_to_ESP8266
### Software

ESPlorer for uploading code using Lua 
https://esp8266.ru/esplorer/ 

Firmware provided from the cloud build
https://nodemcu-build.com/

ESPEasy to flash firmware(provided in dir) 
https://github.com/letscontrolit/ESPEasy

IFTTT app on Android https://ifttt.com/home

Free webhost server to store a single char using PHP
https://www.000webhost.com/


### Hardware
NodeMCU esp8266 from Aliexpress

2x 2N2222

LM7805 to provide 5.0V

12V power adapter

### Datasheets
LM7805
https://www.mouser.com/datasheet/2/149/LM7805-1010961.pdf

ESP8266
 https://www.espressif.com/sites/default/files/documentation/0a-esp8266ex_datasheet_en.pdf

2N2222
 https://www.electroschematics.com/wp-content/uploads/2009/04/2n2222-datasheet.pdf

Relay Dev Board [this is a link to an Active LOW board, the one I used is actually Active HIGH]
http://wiki.sunfounder.cc/index.php?title=8_Channel_5V_Relay_Module

NodeMCU
 https://components101.com/development-boards/nodemcu-esp8266-pinout-features-and-datasheet
