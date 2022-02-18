# FloodNet gateway setup
## Introduction
<img src="https://www.floodnet.nyc/wp-content/uploads/2021/04/floodnet_logomark-2.png" width="20%" align="right">
This repository houses all the setup and deployment information for the FloodnNet project's LoRaWAN gateways. Gateway hardware and setups are in flux so could change at any time. We will try and keep this repo up to date buts its advisable to contact info@floodnet.nyc before starting a setup or install in case there are changes to make.

## Summary of deployment needs
A FloodNet sensor gateway picks up transmissions from our street level flood sensors mounted within around 2 km of the gateway. The gateway can be mounted inside or outside but its 3 foot antenna should be mounted as high as possible outside. Mounting points such as railings or existing vertical poles are needed to ensure the gateway and antenna are securely fastened. The gateway also requires a continuous power source such as a domestic power outlet. It measures 7 x 7 x 2 inches, weighs 1 pound, and consumes around 10 watts of power (similar to a small phone charger). To provide the gateway with an intenrt connection an easy way to connect the gateway to an internet connected router via ethernet cable is prefered. The data throughput of the device is minimal at around 5 MB/day. The gateway also includes a cellular connection as a backup if no existing wired internet is available.

## Gateway hardware
We are currently trialing the [MikroTik LtAP LTE kit (RRP: $179)](https://mikrotik.com/product/ltap_lte_kit) as it provides an in-built: LTE modem that handles US bands with internal antenna, GPS module with internal antenna, and Wi-Fi with internal antenna. There is a spare PCI-E slot inside the MikroTik LtAP LTE kit which allows you to add a [LoRa concentrator card (RRP: $89)](https://mikrotik.com/product/r11e_lr9) to enable it as a LoRaWAN gateway.

The gateway 

For most installations you will be looking for a high gain antenna (~3ft in length) mounted in an un-occluded spot, as high as possible from the ground and any metal surfaces. This will provide you with more LoRa coverage for your sensors. We have used the [SignalPlus 10dBi antenna (Amazon: $85)](https://www.amazon.com/gp/product/B0927J1DCX) which feels solid, provides decent coverage, and comes with 32ft of rugged looking RG58 antenna cable.

* NB1: never power up the gateway without the antenna plugged in, it can fry the LoRa board!
* NB2: always ground yourself properly when touching these LoRa cards as they are sensitive to static shock

## Gateway power consumption
We have measured the power consumption of the MikroTik LtAP LTE gateway at 12W when running the: LTE module, Wi-Fi, GPS and LoRa module. Its powered using a 24V supply that draws around 500mA. We use a POE injector to push the 24V up CAT5 cabling that can run upto 50ft without an issue of voltage drop.

## Internet backhaul
A LoRaWAN gateway needs an internet connection to forward LoRa packets up to network providers such as [The Things Industries](https://www.thethingsindustries.com), which we use for this project. Internet connectivity via Ethernet is recommended for stability with cellular connectivity as a backup. In some cases the ethernet option may not be available so cell can be used but expect more downtime.

We have a cell only gateway deployed in Red Hook that uses an [Embedded Works 64kbps unlimited SIM (RRP: $48/12months)](https://www.embeddedworks.net/wsim4827). This can handle the LoRaWAN traffic easily within its throttled 64kbps bandwidth. One downside is that its only valid for 12 months so would need swapping out.

## Gateway setup via Winbox
We have created a setup script for the gateway that assumes you are running the RouterOS firmware version 6.49.1. This is setup to: create a secured Wi-Fi network for nearby config if needed, establish an LTE connection, setup GPS, set timezone and NTP servers, create a DHCP server for Wi-Fi access IP allocations, set DNS servers to Google defaults, setup LoRaWAN servers for US use, and create a watchdog that restarts the device if a ping times out after 2m to 8.8.8.8.

The [setup file can be found here](config/floodnet-ltap-gw-dec-2021.cfg.rsc) and needs some editing to add in some sensitive info:

* Replace `<WIFI-PASSWORD_HERE>` with the secure Wi-Fi password of your choosing

We have used macs to set these up so use the [WinBox for Mac port](https://github.com/nrlquaker/winbox-mac).

1. Plug in the factory default Mikrotik LtAP LTE kit
2. Connect to its open Wi-Fi network
3. Connect to it using `192.168.88.1` with user `admin` and leave the password field empty
4. [Upgrade/downgrade firmware](https://wiki.mikrotik.com/wiki/Manual:Upgrading_RouterOS) to match the config files 6.49.1
5. Install the Lora package by [downloading this](https://download.mikrotik.com/routeros/6.49.1/all_packages-mmips-6.49.1.zip) and [installing according to this](https://systemzone.net/how-to-install-extra-packages-in-mikrotik)
6. Follow the [instructions here](https://jcutrer.com/howto/networking/mikrotik/mikrotik-backup-and-restore) under the heading: `Text Config Restore .rsc Text File`


## Rain gauge setup (TODO)

## Example deployment images
### Red Hook
<img src="img/gw-main.jpg" width="100%">
<img src="img/stack-view.jpg" width="100%">
<img src="img/antenna-close.jpg" width="100%">
<img src="img/antenna-view.jpg" width="100%">
<img src="img/rain-gauge.jpg" width="100%">

------------------------------------------------------------------------------------------------------------------------
Shield: [![CC BY-NC-SA 4.0][cc-by-nc-sa-shield]][cc-by-nc-sa]

This work is licensed under a
[Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License][cc-by-nc-sa].

[![CC BY-NC-SA 4.0][cc-by-nc-sa-image]][cc-by-nc-sa]

[cc-by-nc-sa]: http://creativecommons.org/licenses/by-nc-sa/4.0/
[cc-by-nc-sa-image]: https://licensebuttons.net/l/by-nc-sa/4.0/88x31.png
[cc-by-nc-sa-shield]: https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-lightgrey.svg

