# dec/06/2021 19:36:48 by RouterOS 6.49.1
# software id = YU5M-76BC
#
:delay 15s
/interface lte
set [ find ] allow-roaming=no mtu=1420 name=lte1
/interface wireless
set [ find default-name=wlan1 ] antenna-gain=0 band=2ghz-b/g/n channel-width=\
    20/40mhz-XX country="united states" disabled=no frequency=auto \
    frequency-mode=manual-txpower mode=ap-bridge ssid=floodnet-ltap-ap \
    station-roaming=enabled wps-mode=disabled
/interface lte apn
set [ find default=yes ] apn=m2mglobal name=EW
/interface wireless security-profiles
set [ find default=yes ] authentication-types=wpa2-psk eap-methods="" mode=\
    dynamic-keys supplicant-identity=MikroTik wpa2-pre-shared-key=<WIFI-PASSWORD_HERE>
/ip pool
add name=dhcp_pool1 ranges=192.168.1.2-192.168.1.254
add name=dhcp_pool2 ranges=192.168.88.2-192.168.88.254
/ip dhcp-server
add address-pool=dhcp_pool2 disabled=no interface=wlan1 name=dhcp1
/lora servers
add address=nam1.cloud.thethings.industries down-port=1700 name=\
    "TTS Cloud (nam1)" up-port=1700
add address=nam1.cloud.thethings.network down-port=1700 name="TTN V3 (nam1)" \
    up-port=1700
add address=eu.mikrotik.thethings.industries down-port=1700 name=TTN-EU \
    up-port=1700
add address=us.mikrotik.thethings.industries down-port=1700 name=TTN-US \
    up-port=1700
add address=eu1.cloud.thethings.industries down-port=1700 name=\
    "TTS Cloud (eu1)" up-port=1700
add address=au1.cloud.thethings.industries down-port=1700 name=\
    "TTS Cloud (au1)" up-port=1700
add address=eu1.cloud.thethings.network down-port=1700 name="TTN V3 (eu1)" \
    up-port=1700
add address=au1.cloud.thethings.network down-port=1700 name="TTN V3 (au1)" \
    up-port=1700
/port
set 1 baud-rate=115200
/user group
set full policy="local,telnet,ssh,ftp,reboot,read,write,policy,test,winbox,pas\
    sword,web,sniff,sensitive,api,romon,dude,tikapp"
/interface bridge port
add comment=defconf interface=ether1
add comment=defconf interface=wlan1
/ip neighbor discovery-settings
set discover-interface-list=!dynamic
/interface detect-internet
set detect-interface-list=all internet-interface-list=all
/ip address
add address=192.168.88.1/24 interface=wlan1 network=192.168.88.0
/ip cloud
set ddns-enabled=yes
/ip dhcp-client
add comment=defconf disabled=no
/ip dhcp-server network
add address=192.168.0.0/24 dns-server=8.8.8.8,8.8.4.4,192.168.1.1 gateway=\
    192.168.0.1
add address=192.168.1.0/24 dns-server=8.8.8.8,8.8.4.4,192.168.1.1 gateway=\
    192.168.1.1
add address=192.168.88.0/24 comment=defconf dns-server=\
    192.168.88.1,172.17.1.101,172.17.1.102 gateway=192.168.88.1
/ip dns
set servers=8.8.8.8,8.8.4.4
/ip ssh
set forwarding-enabled=remote
/lora
set 0 antenna=uFL disabled=no servers="TTN V3 (nam1),TTS Cloud (nam1)"
/system clock
set time-zone-name=America/New_York
/system console
set [ find ] disabled=yes
/system gps
set enabled=yes port=serial1 set-system-time=yes
/system identity
set name=floodnet-ltap-gw
/system leds
set 0 interface=lte1 leds="" type=interface-status
/system logging
add topics=lte
add topics=lora
/system ntp client
set enabled=yes primary-ntp=216.239.35.0 secondary-ntp=216.239.35.4
/system watchdog
set ping-start-after-boot=10m ping-timeout=2m watch-address=8.8.8.8
