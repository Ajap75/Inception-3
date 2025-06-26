#!/bin/sh
set -e

rm -rf /run/mysqld
mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

# Si base déjà initialisée
if [ -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    exec mysqld
fi

echo "[MariaDB INIT] First start, initializing DB and user..."

# Initialisation de la base
mysql_install_db --user=mysql --datadir=/var/lib/mysql

mysqld_safe --skip-networking &
pid="$!"

for i in $(seq 30); do
    if mysqladmin ping --silent; then
        break
    fi
    echo "Waiting for MariaDB to be ready... ($((30-i)))"
    sleep 1
done

if ! mysqladmin ping --silent; then
    echo "MariaDB init process failed: server didn't start"
    exit 1
fi

# Sécurise le mot de passe root et crée la base/user WP
mysql -u root <<-EOSQL
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
    CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` ;
    CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
    GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
    FLUSH PRIVILEGES;
EOSQL

kill "$pid"
wait "$pid"

echo "[MariaDB INIT] Initialization done. Starting real server."
exec mysqld
