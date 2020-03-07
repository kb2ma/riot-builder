# Setup for Networking Apps
RIOT supports several IP networking environments for running an app -- native (on workstation), USB via ethos, Wi-Fi on ESP platforms, etc. The setup for an environment is essentially the same regardless of the particular application to run. So, this document is a guide to building and running a RIOT application in various environments.

## Environments
This document describes the setup for these environments:

| Name | Description |
| ---- | ----------- |
| native | development workstation, Linux |
| usb | Uses the RIOT ethos tool (in `./dist/tools/ethos`) for Ethernet over USB serial |
| 6lo | 6LowPAN over 802.15.4 |
| inet | IPv6 over WiFi, using RIOT's GNRC library |
| inet.lwip | IPv6 over WiFi, using lwIP library |
| inet4.lwip | IPv4 over WiFi, using lwIP library |

The setup instructions below for individual environments assume a client/server based networking application like gcoap.

## native
Setup for a single Linux native node connecting via TAP to a node on the workstation.

```
RIOT native process
fd00:bbbb::2/64
   |
  TAP
   |
Workstation (Linux)
fd00:bbbb::1/64
```

Must manually run '`setup_tap.sh start`' to setup TAP, and '`setup_tap.sh stop`' to tear it down. The start script sets the address for the workstation.

After running the `term` target to start the RIOT instance, set the network address in its terminal:

```
   > ifconfig 6 add fd00:bbbb::2/64
```


## usb
Setup for a single physical board node connecting via USB/TAP to a node on the workstation. I use a samr21-xpro. Build with `Makefile.ula`.
```
RIOT board (samr21-xpro)
fd00:bbbb::2/64 
   |
  USB/TAP
   |
Workstation (Linux)
fd00:bbbb::1/64
```

`start_network_kb.sh` executes automatically when running the `term` target for the board, to setup and teardown the TAP interface.

After running the `term` target on the board, do the following:

**board**
```
   > ifconfig 6 add fd00:bbbb::2/64
   > nib neigh add 6 fd00:bbbb::1 <ether addr>
```
where <ether addr\> is the 6 hexadecimal colon separated MAC address of the TAP interface on the workstation.

**workstation**
```
   $ sudo ip route add fd00:bbbb::/64 via <lladdr> dev tap0
```
where <lladdr\> is the link local address of the samr21-xpro

## 6lo
Setup for a physical board that connects to a node on the workstation via an intermediate border router also on a physical board. The border router is built with `examples/gnrc_border_router`. It has a USB interface to the workstation.

```
RIOT board (6lo on samr21-xpro)
fd00:aaaa::xxxx/64
   |
   6LoWPAN 802.15.4
   |
fd00:aaaa::xxxx/64
RIOT board (border router "br" on samr21-xpro)
(no routable address on fd00:bbbb)
   |
  USB/TAP
   |
workstation (Linux)
uhcpd generates fd00:aaaa::/64 addresses
fd00:bbbb::1/64
```

`start_network_kb.sh` executes automatically when running the `term` target for the board, to setup and teardown the TAP interface. Also, uhcpd generates fd00:aaaa::/64 addresses and installs them on both RIOT boards. So there is no additional setup.

## inet
Setup for a single physical board client node connected via WiFi to a server node in the cloud. I use ESP-12x (8266) Adafruit Feather board because it has WiFi on board, and so does not require a USB connection to an Internet gateway, like the samr21-xpro. This approach means we expect the WiFi access point to provide IPv6 Internet connectivity. Build with `Makefile.inet`.
```
RIOT board (esp-12x)
routeable IPv6 addr (auto-assigned)
   |
  WiFi/Internet
   |
cloud instance (Linux)
routeable cloud address (see SERVER_ADDR below)
```

Must define environment variables for `Makefile.inet`:
```
export RIOT_WIFI_SSID="<ssid>"
export RIOT_WIFI_PASS="<passphrase>"
export SERVER_ADDR=\\\"<server addr>\\\"

