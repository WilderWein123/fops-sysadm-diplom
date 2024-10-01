#!/bin/bash
wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_7.0-2+ubuntu22.04_all.deb
dpkg -i zabbix-release_7.0-2+ubuntu22.04_all.deb
apt update
apt install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent mysql-server -y
sudo mysql -uroot -e "create user zabbixUser@localhost identified by 'password123';"
sudo mysql -uroot -e "create database zabbixDB character set utf8 collate utf8_bin;" 
sudo mysql -uroot -e "grant all privileges on zabbixDB.* to zabbixUser@localhost;"
sudo mysql -uroot -e "FLUSH PRIVILEGES;"
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | sudo mysql -uroot zabbix
