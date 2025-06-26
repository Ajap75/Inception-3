#!/bin/sh
set -e

# 1. Crée le dossier socket si besoin
rm -rf /run/mysqld
mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

# 2. Si la base existe déjà, on lance direct le serveur MariaDB normal
if [ -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    exec mysqld
fi

echo "[MariaDB INIT] First start, initializing DB and user..."

# 3. Lance MariaDB en arrière-plan (pour l'init)
mysqld_safe --skip-networking &
pid="$!"

# 4. Attend que MariaDB soit prêt
for i in {30..0}; do
    if mysql -u root -e "SELECT 1" >/dev/null 2>&1; then
        break
    fi
    echo "Waiting for MariaDB to be ready ($i)..."
    sleep 1
done

if [ "$i" = 0 ]; then
    echo >&2 "MariaDB init process failed: server didn't start"
    exit 1
fi

# 5. Création de la base, du user et des droits
mysql -u root <<-EOSQL
    CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` ;
    CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
    GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
    FLUSH PRIVILEGES;
EOSQL

# 6. Arrête proprement MariaDB temporaire
if ! kill -s TERM "$pid" || ! wait "$pid"; then
    echo >&2 '[ERROR] MariaDB init process failed.'
    exit 1
fi

echo "[MariaDB INIT] Initialization done. Starting real server."

# 7. Lance le vrai serveur MariaDB en avant-plan
exec mysqld
