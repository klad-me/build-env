#! /bin/bash

if [ `whoami` == "root" ]; then
	if [ "$REAL_GROUP_ID" != "" ]; then
		groupmod -g $REAL_GROUP_ID user
	fi
	if [ "$REAL_USER_ID" != "" ]; then
		usermod -u $REAL_USER_ID user
	fi
	sudo -u user docker-entrypoint.sh $@
else
	source ~/.profile
	exec $@
fi
