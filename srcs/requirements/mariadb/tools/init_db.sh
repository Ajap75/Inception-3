#!/bin/sh
set -e

# !! PLUS BESOIN de manipuler /run/mysqld ici, c'est fait dans le Dockerfile !!

# Si la base existe déjà, on lance le serveur normal
if [ -d "/var/lib/mysql/mysql" ]; then
    exec mysqld
fi

echo "[MariaDB INIT] First start, initializing DB and user..."

# Initialisation de la base (normalement, déjà fait au build, mais ça ne coûte rien de le refaire)
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

# 1. Définit le mot de passe root (sans password)
mysql -u root <<-EOSQL
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
    FLUSH PRIVILEGES;
EOSQL

# 2. Crée la base, l'utilisateur, les droits (maintenant AVEC mot de passe root)
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<-EOSQL
    CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` ;
    CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
    GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
    FLUSH PRIVILEGES;
EOSQL

kill "$pid"
wait "$pid"
sleep 2

echo "[MariaDB INIT] Initialization done. Starting real server."
exec mysqld
