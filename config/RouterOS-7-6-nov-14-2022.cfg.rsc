# nov/14/2022 17:22:24 by RouterOS 7.6
# software id = XXXX
#
# model = RBLtAP-2HnD
# serial number = XXXX
/interface bridge
add admin-mac=48:8F:5A:F2:29:DF auto-mac=no comment=defconf name=bridge
/interface lte
set [ find default-name=lte1 ] allow-roaming=no
/interface wireless
set [ find default-name=wlan1 ] band=2ghz-b/g/n channel-width=20/40mhz-XX \
    country="united states" disabled=no distance=indoors frequency=auto \
    installation=outdoor mode=ap-bridge ssid=floodnet-ltap-ap \
    wireless-protocol=802.11
/interface list
add comment=defconf name=WAN
add comment=defconf name=LAN
/interface lte apn
set [ find default=yes ] apn=m2mglobal use-network-apn=no
/interface wireless security-profiles
set [ find default=yes ] authentication-types=wpa2-psk eap-methods="" mode=\
    dynamic-keys supplicant-identity=MikroTik
/ip pool
add name=default-dhcp ranges=192.168.88.10-192.168.88.254
/ip dhcp-server
add address-pool=default-dhcp interface=bridge name=defconf
/lora servers
add address=eu.mikrotik.thethings.industries down-port=1700 name=TTN-EU \
    up-port=1700
add address=us.mikrotik.thethings.industries down-port=1700 name=TTN-US \
    up-port=1700
add address=eu1.cloud.thethings.industries down-port=1700 name=\
    "TTS Cloud (eu1)" up-port=1700
add address=nam1.cloud.thethings.industries down-port=1700 name=\
    "TTS Cloud (nam1)" up-port=1700
add address=au1.cloud.thethings.industries down-port=1700 name=\
    "TTS Cloud (au1)" up-port=1700
add address=eu1.cloud.thethings.network down-port=1700 name="TTN V3 (eu1)" \
    up-port=1700
add address=nam1.cloud.thethings.network down-port=1700 name="TTN V3 (nam1)" \
    up-port=1700
add address=au1.cloud.thethings.network down-port=1700 name="TTN V3 (au1)" \
    up-port=1700
/port
set 0 name=serial0
/interface bridge port
add bridge=bridge comment=defconf interface=ether1
add bridge=bridge comment=defconf interface=wlan1
/ip neighbor discovery-settings
set discover-interface-list=LAN
/interface list member
add comment=defconf interface=bridge list=LAN
add comment=defconf interface=lte1 list=WAN
/ip address
add address=192.168.88.1/24 comment=defconf interface=bridge network=\
    192.168.88.0
/ip dhcp-server network
add address=192.168.88.0/24 comment=defconf dns-server=192.168.88.1 gateway=\
    192.168.88.1
/ip dns
set allow-remote-requests=yes
/ip dns static
add address=192.168.88.1 comment=defconf name=router.lan
/ip firewall filter
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
/ip firewall nat
add action=masquerade chain=srcnat comment="defconf: masquerade" \
    ipsec-policy=out,none out-interface-list=WAN
/ipv6 firewall address-list
add address=::/128 comment="defconf: unspecified address" list=bad_ipv6
add address=::1/128 comment="defconf: lo" list=bad_ipv6
add address=fec0::/10 comment="defconf: site-local" list=bad_ipv6
add address=::ffff:0.0.0.0/96 comment="defconf: ipv4-mapped" list=bad_ipv6
add address=::/96 comment="defconf: ipv4 compat" list=bad_ipv6
add address=100::/64 comment="defconf: discard only " list=bad_ipv6
add address=2001:db8::/32 comment="defconf: documentation" list=bad_ipv6
add address=2001:10::/28 comment="defconf: ORCHID" list=bad_ipv6
add address=3ffe::/16 comment="defconf: 6bone" list=bad_ipv6
/ipv6 firewall filter
add action=accept chain=input comment=\
    "defconf: accept established,related,untracked" connection-state=\
    established,related,untracked
add action=drop chain=input comment="defconf: drop invalid" connection-state=\
    invalid
add action=accept chain=input comment="defconf: accept ICMPv6" protocol=\
    icmpv6
add action=accept chain=input comment="defconf: accept UDP traceroute" port=\
    33434-33534 protocol=udp
add action=accept chain=input comment=\
    "defconf: accept DHCPv6-Client prefix delegation." dst-port=546 protocol=\
    udp src-address=fe80::/10
add action=accept chain=input comment="defconf: accept IKE" dst-port=500,4500 \
    protocol=udp
add action=accept chain=input comment="defconf: accept ipsec AH" protocol=\
    ipsec-ah
add action=accept chain=input comment="defconf: accept ipsec ESP" protocol=\
    ipsec-esp
add action=accept chain=input comment=\
    "defconf: accept all that matches ipsec policy" ipsec-policy=in,ipsec
add action=drop chain=input comment=\
    "defconf: drop everything else not coming from LAN" in-interface-list=\
    !LAN
add action=accept chain=forward comment=\
    "defconf: accept established,related,untracked" connection-state=\
    established,related,untracked
add action=drop chain=forward comment="defconf: drop invalid" \
    connection-state=invalid
add action=drop chain=forward comment=\
    "defconf: drop packets with bad src ipv6" src-address-list=bad_ipv6
add action=drop chain=forward comment=\
    "defconf: drop packets with bad dst ipv6" dst-address-list=bad_ipv6
add action=drop chain=forward comment="defconf: rfc4890 drop hop-limit=1" \
    hop-limit=equal:1 protocol=icmpv6
add action=accept chain=forward comment="defconf: accept ICMPv6" protocol=\
    icmpv6
add action=accept chain=forward comment="defconf: accept HIP" protocol=139
add action=accept chain=forward comment="defconf: accept IKE" dst-port=\
    500,4500 protocol=udp
add action=accept chain=forward comment="defconf: accept ipsec AH" protocol=\
    ipsec-ah
add action=accept chain=forward comment="defconf: accept ipsec ESP" protocol=\
    ipsec-esp
add action=accept chain=forward comment=\
    "defconf: accept all that matches ipsec policy" ipsec-policy=in,ipsec
add action=drop chain=forward comment=\
    "defconf: drop everything else not coming from LAN" in-interface-list=\
    !LAN
/lora
set 0 antenna=uFL disabled=no name=<ENTER LORA GATEWAY NAME HERE> servers=\
    "TTN V3 (nam1),TTN-US,TTS Cloud (nam1)"
/system clock
set time-zone-name=America/New_York
/system gps
set enabled=yes port=gps
/system identity
set name=floodnet-ltap-gw
/system leds
# using RSRP, modem-signal-threshold ignored
set 0 interface=lte1
add interface=lte1 leds=user-led type=interface-status
/system package update
set channel=development
/system scheduler
add interval=10s name=lora_watchdog on-event="if (put [len [/lora print as-val\
    ue;]] < 1) do={/system routerboard usb power-reset bus=0 duration=5s; /lor\
    a enable 0;} else={/lora enable 0;}" policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-date=oct/28/2022 start-time=10:05:42
/system watchdog
set ping-timeout=2m watch-address=8.8.8.8
/tool mac-server
set allowed-interface-list=LAN
/tool mac-server mac-winbox
set allowed-interface-list=LAN
