#!/bin/bash
# Build script for RIOT apps, with useful parameters

if [ -n "$1" ]; then
    flavor="$1"
else
    echo "Must specify flavor: (native|usb|6lo|br|inet|inet.lwip|inet4.lwip)"
    exit 1
fi

# target must be clean|all|flash|term
if [ -n "$2" ]; then
    target="$2"
else
    target="all"
fi

if [ -z "${APP_DIR}" ]; then
    echo "Must specify APP_DIR"
fi

# Allow override for unusual setups
makefile="Makefile"

if [ "$flavor" = "usb" ]; then
    makefile="Makefile.usb"
    export IPV6_PREFIX="fd00:bbbb"
    export BOARD="samr21-xpro"

elif [ "$flavor" = "6lo" ]; then
    export BOARD="samr21-xpro"

elif [ "$flavor" = "br" ]; then
    export BOARD="samr21-xpro"
    export IPV6_PREFIX="fd00:bbbb"
    export INT_PREFIX="fd00:aaaa::/64"

elif [ "$flavor" = "native" ]; then
    # only need for DTLS, but does no harm otherwise
    export CFLAGS="${CFLAGS} -DDTLS_PEER_MAX=2"

# notice regex lookup
elif [[ "$flavor" =~ inet* ]]; then

    # Use Adafruit Feather ESP8266
    export BOARD="esp8266-esp-12x"
    export USEMODULE="esp_wifi"
    export CFLAGS="${CFLAGS} -DESP_WIFI_SSID=\\\"${RIOT_WIFI_SSID}\\\""
    export CFLAGS="${CFLAGS} -DESP_WIFI_PASS=\\\"${RIOT_WIFI_PASS}\\\""
    # required since addition of sock_async; default of 1108 not enough on esp8266
    export CFLAGS="${CFLAGS} -DGCOAP_STACK_SIZE=2048"
fi

if [ "$flavor" = "inet.lwip" ]; then
    export LWIP_IPV6=1
    export LWIP_IPV4=0
elif [ "$flavor" = "inet4.lwip" ]; then
    export LWIP_IPV4=1
    export LWIP_IPV6=0
fi

if [ "$target" = "flash" ] && [ -n ${SERIAL} ]; then
    make -C ${APP_DIR} -f $makefile $target SERIAL="${SERIAL}"
elif [ "$target" = "term" ] && [ -n ${PORT} ]; then
    make -C ${APP_DIR} -f $makefile $target PORT="${PORT}"
else
    make -C ${APP_DIR} -f $makefile $target
fi
