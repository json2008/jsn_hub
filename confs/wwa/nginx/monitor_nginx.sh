#!/bin/bash
A=`ps -C nginx --no-header | wc -l` 
if [ $A -eq 0 ];then
/usr/sbin/nginx
sleep 3
if [ `ps -C nginx --no-header | wc -l` -eq 0 ];then
killall keepalived 
fi

fi
