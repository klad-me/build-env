#! /bin/bash

if [ `id -u` == 0 ]; then
	echo "Don't run as root !"
	exit -1
fi


docker run -it --rm \
	-w /project \
	-e REAL_USER_ID=$(id -u ${USER}) \
	-e REAL_GROUP_ID=$(id -g ${USER}) \
	-v $PWD:/project \
	kladme/build-env:0.1 \
	$@
