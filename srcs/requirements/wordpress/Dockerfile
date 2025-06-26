# ==========================================================================
# Dockerfile de l'image WordPress custom pour le projet Inception
# Ce fichier crée un conteneur PHP-FPM prêt à installer et exécuter WordPress
# ==========================================================================

# 1. Base de l'image : Debian "bookworm"
FROM debian:bookworm
# Pourquoi ? Debian est léger, stable, maintenu à long terme, et autorisé par le sujet.

# 2. Installation de PHP (version FPM pour serveur), de l'extension MySQL et de curl
RUN apt-get update && apt-get install -y php-fpm php-mysql curl mariadb-client
# - php-fpm : moteur PHP pour servir les requêtes dynamiquement
# - php-mysql : module permettant à PHP de parler à MariaDB/MySQL
# - curl : utilitaire pour télécharger WP-CLI

# 3. Installation de WP-CLI (outil en ligne de commande pour piloter WordPress)
RUN curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp
# - Télécharge l'outil wp-cli officiel (format .phar)
# - Place le binaire dans /usr/local/bin (chemin classique pour les exécutables système)
# - Donne les droits d'exécution

# 4. Prépare le dossier d'accueil de WordPress
RUN mkdir -p /var/www/wordpress
# - Ce sera le "volume" partagé avec NGINX et la VM pour la persistance

# 5. Ajoute le script d'installation/configuration WordPress dans l'image
COPY conf/setup.sh /tmp/setup.sh
RUN chmod +x /tmp/setup.sh
# - On copie le script qui va : attendre MariaDB, installer WordPress, créer les users...
# - On lui donne le droit d'exécution pour qu'il puisse être lancé comme programme principal

# 6. Ouvre le port 9000 (utilisé par PHP-FPM pour communiquer avec NGINX)
EXPOSE 9000
# - Permet à NGINX de passer les requêtes PHP au service WordPress

# 7. Point d'entrée : on lance le script setup.sh
CMD ["/tmp/setup.sh"]
# - Quand le conteneur démarre, il exécute setup.sh
#   - Ce script va attendre la BDD, installer WordPress si besoin, créer admin/user, puis lancer PHP-FPM au premier plan (foreground)
