FROM alpine:3.18

# System utils
RUN \
	   apk --no-cache add mc wget curl xxd zip bash sudo shadow \
	&& rm /bin/sh \
	&& ln -s /bin/bash /bin/sh


# Host build utils
RUN apk --no-cache add gcc g++ make cmake git nodejs python3 py3-pip libc6-compat gcompat libusb bison flex


# env-diff util (for esp32 env)
RUN \
	   git clone https://github.com/klad-me/env-diff /env-diff \
	&& cd /env-diff \
	&&   make install \
	&& cd .. \
	&& rm -rf /env-diff


# Adding user
RUN \
	   groupadd -g 5555 user \
	&& useradd -u 5555 -g user -s /bin/bash user \
	&& mkdir /home/user \
	&& touch /home/user/.profile \
	&& chown -R user.user /home/user


# arm-gcc
RUN apk --no-cache add binutils-arm-none-eabi gcc-arm-none-eabi g++-arm-none-eabi newlib-arm-none-eabi


# avr-gcc
RUN apk --no-cache add binutils-avr gcc-avr avr-libc


# ESP8266 SDK
COPY ./esp8266 /usr/local/esp8266
RUN \
	   mkdir /usr/local/esp8266/bin \
	&& cd /usr/local/esp8266/esptool2 \
	&&   make \
	&&   mv esptool2 ../bin \
	&& cd .. \
	&& rm -rf esptool2 \
	&& cd fota-fw \
	&&   make \
	&&   mv fota-fw ../bin \
	&& cd .. \
	&& rm -rf fota-fw \
	&& echo "# ESP8266 exports" >>/home/user/.profile \
	&& echo "export PATH=/usr/local/esp8266/bin:/usr/local/esp8266/xtensa-lx106-elf/bin:\$PATH" >>/home/user/.profile


# ESP32 SDK
USER user
RUN \
	   git clone --recursive https://github.com/espressif/esp-idf.git ~/esp-idf \
	&& cd ~/esp-idf \
	&&   git checkout 2f9d47c708 \
	&&   git submodule update \
	&&   rm -rf .git docs examples \
	&&   ./install.sh esp32 \
	&&   TMP=`mktemp` \
	&&   env >$TMP \
	&&   . ./export.sh \
	&&   echo "# ESP-IDF exports" >>~/.profile \
	&&   env-diff -s -p -b $TMP >>~/.profile
USER root


# SDCC for STM8 & 8051
COPY ./makeinfo /usr/bin
RUN \
	chmod 755 /usr/bin/makeinfo \
	&& apk --no-cache add boost-dev \
	&& wget -O sdcc-src-4.2.0.tar.bz2 https://sourceforge.net/projects/sdcc/files/sdcc/4.2.0/sdcc-src-4.2.0.tar.bz2/download \
	&& tar -xvf sdcc-src-4.2.0.tar.bz2 \
	&& cd sdcc-4.2.0 \
	&&   ./configure \
		   --disable-z80-port --disable-z180-port --disable-r2k-port --disable-r2ka-port --disable-r3ka-port \
		   --disable-gbz80-port --disable-tlcs90-port --disable-ez80_z80-port --disable-z80n-port --disable-ds390-port \
		   --disable-ds400-port --disable-pic14-port --disable-pic16-port --disable-hc08-port --disable-s08-port \
		   --disable-pdk13-port --disable-pdk14-port --disable-pdk15-port --disable-pdk16-port --disable-ucsim --disable-doc \
	&&   make \
	&&   make install \
	&& cd / \
	&& rm -rf /sdcc-src-4.2.0.tar.bz2 /sdcc-4.2.0 \
	&& apk --no-cache del boost-dev




# Entrypoint
COPY ./docker-entrypoint.sh /usr/bin
RUN chmod 755 /usr/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]
