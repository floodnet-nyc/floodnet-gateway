:delay 60s

# Disable roaming on LTE card
/interface lte
set [ find default-name=lte1 ] allow-roaming=no disabled=no network-mode=lte

# Set LTE APN string for EmbeddedWorks SIM card
/interface lte apn
set [ find default=yes ] apn=m2mglobal name=default

# Set timezone to NY
/system clock
set time-zone-name=America/New_York

# Enable GPS
/system gps
set enabled=yes port=gps

# Set WiFi LED to light when device is connected to wlan1
/system leds
add interface=wlan1 leds=user-led type=interface-status

# Set 5 signal level LEDs to show cellular signal strength
/system leds
set 0 interface=lte1 leds="led1,led2,led3,led4,led5" type=modem-signal

# Set router name
/system identity
set name=floodnet-ltap-gw

# Create WAN interface list
/interface list
add name=WAN

# Add ether1 and lte1 to WAN interface list
/interface list member
add comment=defconf interface=ether1 list=WAN
add interface=lte1 list=WAN

# Create IP pool for WiFi DHCP server
/ip pool
add name=dhcp-pool ranges=192.168.88.10-192.168.88.254

# Create DHCP server for WiFi and assign previously created pool
/ip dhcp-server
add address-pool=dhcp-pool interface=wlan1 name=dhcp

# Create IP address and network for WiFi adapter
/ip address
add address=192.168.88.1/24 interface=wlan1 network=192.168.88.0

# Create network setup for WiFi DHCP server
/ip dhcp-server network
add address=192.168.88.0/24 dns-server=1.1.1.1,8.8.8.8 gateway=192.168.88.1 \
    netmask=24 ntp-server=129.6.15.28,129.6.15.29

# Create DHCP client for ethernet so it accepts an external DHCP server assigned IP addresses
/ip dhcp-client
add interface=ether1

# Set google DNS servers
/ip dns
set allow-remote-requests=yes servers=8.8.8.8,8.8.4.4

# Turns on verbose logging for lte on Log for debugging
/system logging
add topics=lte

# Setup Wi-Fi network
/interface wireless
set [ find default-name=wlan1 ] band=2ghz-b/g/n channel-width=20/40mhz-XX \
    country="united states" disabled=no distance=indoors frequency=auto \
    installation=outdoor mode=ap-bridge ssid=floodnet-ltap-ap \
    wireless-protocol=802.11

# Setup Wi-Fi security config
/interface wireless security-profiles
set [ find default=yes ] authentication-types=wpa2-psk eap-methods="" mode=\
    dynamic-keys supplicant-identity=MikroTik wpa2-pre-shared-key=<WIFI-PASSWORD>

# Set USB type to allow use of mini PCIe cards and wait for bring-up
/system routerboard usb set type=mini-PCIe
:delay 10s

# Remove all existing LoRa servers
/lora servers
remove [find up-port="1700"]

# Add US TTN LoRa servers
/lora servers
add address=us.mikrotik.thethings.industries down-port=1700 name=TTN-US \
    up-port=1700
add address=nam1.cloud.thethings.industries down-port=1700 name=\
    "TTS Cloud (nam1)" up-port=1700
add address=nam1.cloud.thethings.network down-port=1700 name="TTN V3 (nam1)" \
    up-port=1700

# Set R11e-LR9 config and assign US TTN LoRa servers
/lora
set 0 antenna=uFL disabled=no name="floodnet-ltap-gw-$[:put [/lora get 0 hardware-id]]" \
servers="TTN V3 (nam1),TTN-US,TTS Cloud (nam1)"

# Set internet detect on all interfaces
/interface detect-internet
set detect-interface-list=all internet-interface-list=all lan-interface-list=\
    all wan-interface-list=all

# Turn on DDNS for future use
/ip cloud
set ddns-enabled=yes

# Setup firewall filters
/ip firewall filter
add action=accept chain=input comment="Allow Remote Winbox" in-interface=\
    RemoteWinboxVPN4
add action=accept chain=input comment=\
    "defconf: accept established,related,untracked" connection-state=\
    established,related,untracked
add action=drop chain=input comment="defconf: drop invalid" connection-state=\
    invalid
add action=accept chain=input comment="defconf: accept ICMP" protocol=icmp
add action=accept chain=input comment=\
    "defconf: accept to local loopback (for CAPsMAN)" dst-address=127.0.0.1
add action=drop chain=input comment="defconf: drop all not coming from LAN" \
	in-interface-list=!LAN
add action=accept chain=forward comment="defconf: accept in ipsec policy" \
    ipsec-policy=in,ipsec
add action=accept chain=forward comment="defconf: accept out ipsec policy" \
    ipsec-policy=out,ipsec
add action=fasttrack-connection chain=forward comment="defconf: fasttrack" \
    connection-state=established,related hw-offload=yes
add action=accept chain=forward comment=\
    "defconf: accept established,related, untracked" connection-state=\
    established,related,untracked
add action=drop chain=forward comment="defconf: drop invalid" \
    connection-state=invalid
add action=drop chain=forward comment=\
    "defconf: drop all from WAN not DSTNATed" connection-nat-state=!dstnat \
    connection-state=new in-interface-list=WAN

# Setup firewall NATs for both WAN interfaces: lte1 and ether1
/ip firewall nat
add action=masquerade chain=srcnat comment="defconf: masquerade" \
    ipsec-policy=out,none out-interface-list=WAN
add action=masquerade chain=srcnat comment="defconf: masquerade" disabled=yes \
    ipsec-policy=out,none out-interface=ether1
add action=masquerade chain=srcnat comment="defconf: masquerade" disabled=yes \
    ipsec-policy=out,none out-interface=lte1

# Turn on general internet watchdog reboots device if 8.8.8.8 is not accessible after 10 minutes
/system watchdog
set ping-start-after-boot=10m ping-timeout=2m watch-address=8.8.8.8

# Add 10 minute internet check scheduler script to favor internet over ethernet or LTE if none on ethernet
# Add 10 second LoRa watchdog that checks the LoRa card and brings it back up if its disabled
/system scheduler
add interval=1m name=inet-check on-event="/interface ethernet set ether1 disab\
    led=no\r\
    \n:delay 10s\r\
    \n/ip route set [find gateway=[/ip dhcp-client get [find interface=ether1]\
    \_gateway]] distance=1\r\
    \nif ([/ping 8.8.8.8 interface=ether1 count=1]=0) do={\r\
    \n:log info \"ether1 lost internet - setting ether1 distance to 10\"\r\
    \n/interface lte set lte1 disabled=no\r\
    \n/ip route set [find gateway=[/ip dhcp-client get [find interface=ether1]\
    \_gateway]] distance=10\r\
    \n} else={\r\
    \n:log info \"ether1 has internet - setting ether1 distance to 1\"\r\
    \n/ip route set [find gateway=[/ip dhcp-client get [find interface=ether1]\
    \_gateway]] distance=1\r\
    \n}" policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-date=feb/13/2023 start-time=16:03:21
add interval=10s name=lora_watchdog on-event="if (put [len [/lora print as-val\
    ue;]] < 1) do={/system routerboard usb set type=mini-PCIe; /system routerb\
    oard usb power-reset bus=0 duration=5s; /lora enable 0;} else={/lora enabl\
    e 0;}" policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-date=oct/28/2022 start-time=10:05:42

# Set admin password
/user set admin password=<ADMIN-PASSWORD>