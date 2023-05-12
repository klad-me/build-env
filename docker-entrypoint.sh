#! /bin/bash

if [ `whoami` == "root" ]; then
	groupmod -g $REAL_GROUP_ID user
	usermod -u $REAL_USER_ID user
	sudo -u user docker-entrypoint.sh $@
else
	source ~/.profile
	exec $@
fi
