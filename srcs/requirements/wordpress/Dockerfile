# ==========================================================================
# Dockerfile de l'image WordPress custom pour le projet Inception
# Ce fichier crée un conteneur PHP-FPM prêt à installer et exécuter WordPress
# ==========================================================================

# 1. Base de l'image : Debian "bookworm"
FROM debian:bookworm

# 2. Installation de PHP-FPM, des dépendances MySQL, et curl pour wp-cli
RUN apt-get update && apt-get install -y \
    php-fpm php-mysql \
    mariadb-client default-mysql-client \
    curl \
    && apt-get clean

# 3. Installation de WP-CLI
RUN curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp

# 4. Préparation du dossier WordPress (point de montage / persistance)
RUN mkdir -p /var/www/wordpress

# 5. Ajout du fichier www.conf modifié pour utiliser le port 9000 (au lieu d’un socket)
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

# 6. Ajout du script d’installation WordPress
COPY conf/setup.sh /tmp/setup.sh
RUN chmod +x /tmp/setup.sh

# 7. Exposition du port PHP-FPM
EXPOSE 9000

# 8. Lancement du script de setup comme commande principale
CMD ["/tmp/setup.sh"]
