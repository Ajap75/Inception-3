#!/bin/sh
set -e

# ----------------------------
#  VARIABLES
# ----------------------------
WP_DIR="/var/www/wordpress"

# ----------------------------
#  WAIT FOR THE DATABASE
# ----------------------------

echo "Waiting for MariaDB to be ready..."
echo "Sleeping for a few seconds to let the MariaDB container initialize..."
sleep 10

until mysqladmin ping -h"$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --silent; do
    echo "⏳ MariaDB is not yet available at $MYSQL_HOST:3306, retrying in 2 seconds..."
    sleep 2
done
echo "✅ MariaDB is now accepting connections at $MYSQL_HOST:3306"

# ----------------------------
#  WORDPRESS INSTALLATION
# ----------------------------

if [ ! -f "$WP_DIR/wp-config.php" ]; then
    echo "📥 Downloading WordPress core..."
    wp core download --path="$WP_DIR" --allow-root || { echo "❌ Download failed" ; exit 1; }

    echo "⚙️ Creating wp-config.php..."
    wp config create --path="$WP_DIR" \
        --dbhost="$MYSQL_HOST" \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$MYSQL_PASSWORD" \
        --allow-root || { echo "❌ Config failed" ; exit 1; }

    echo "🚀 Installing WordPress..."
    wp core install --path="$WP_DIR" \
        --url="https://$DOMAIN_NAME" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN" \
        --admin_password="$WP_ADMIN_PWD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email \
        --allow-root || { echo "❌ Install failed" ; exit 1; }

    echo "👤 Creating additional WordPress user..."
    wp user create "$WP_USER" "$WP_USER_EMAIL" \
        --role=author \
        --user_pass="$WP_USER_PWD" \
        --path="$WP_DIR" \
        --allow-root

    echo "✅ WordPress installation completed. Admin user '${WP_ADMIN}' and standard user '${WP_USER}' created."
else
    echo "ℹ️ WordPress is already configured (wp-config.php found). Skipping installation."
fi

# ----------------------------
#  FIX PERMISSIONS FOR NGINX
# ----------------------------
echo "🔐 Setting permissions on $WP_DIR for NGINX (www-data)..."
chown -R www-data:www-data "$WP_DIR"

# ----------------------------
#  START PHP-FPM
# ----------------------------
echo "🚦 Starting PHP-FPM..."
php-fpm8.2 -F
