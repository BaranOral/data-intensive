#! /bin/bash

MASTER_ROOT_PASSWORD=master
MASTER_DATABASE=replication_db
MASTER_USER=master
MASTER_PASSWORD=master
SLAVE_ROOT_PASSWORD=slave
SLAVE_DATABASE=replication_db
SLAVE_USER=slave
SLAVE_PASSWORD=slave

echo $MASTER_USER
echo $SLAVE_USER

CREATE USER 'replication'@'%' IDENTIFIED WITH mysql_native_password BY 'replication'

GRANT REPLICATION SLAVE ON *.* TO 'replication'@'%'
show grants for replication@'%'

SHOW MASTER STATUS\G

CHANGE MASTER TO
MASTER_HOST='master',
MASTER_USER='replication',
MASTER_PASSWORD='replication',
MASTER_LOG_FILE='binlog.000008',
MASTER_LOG_POS=157

START SLAVE

SHOW SLAVE STATUS\G
