#!/bin/sh
stty -F ${1:?need a file argument} \
	115200 -icrnl -ixon -opost -isig -icanon \
	-iexten -echo cs8 -cstopb -parenb

