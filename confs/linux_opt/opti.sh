echo "couchdb - nofile 10240" >> /etc/security/limits.conf
echo "* - nofile 10240" >> /etc/security/limits.conf

#再加上对传输缓冲区的大小调整
ifconfig eth0 txqueuelen 10000

