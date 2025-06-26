#!/bin/bash
set -e

echo "[MariaDB INIT] Initializing..."

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "[MariaDB INIT] Installing system tables..."
    mysql_install_db --user=mysql --ldata=/var/lib/mysql > /dev/null
fi

mysqld_safe --skip-networking &
pid="$!"

echo "[MariaDB INIT] Waiting for server to start..."
while ! mysqladmin ping --silent; do
    sleep 1
done

echo "[MariaDB INIT] Creating DB and user..."
mysql -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"
mysql -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
mysql -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';"
mysql -e "FLUSH PRIVILEGES;"

mysqladmin shutdown

echo "[MariaDB INIT] Launching final mysqld"
exec gosu mysql mysqld