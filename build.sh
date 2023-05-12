#! /bin/bash

if [ ! -d esp8266 ]; then
	tar xvf esp8266.tgz
fi

docker build -t kladme/build-env:0.1 .
