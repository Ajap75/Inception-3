# Utiliser une image de base minimale (debian:bookworm) pour Nginx
FROM debian:bookworm

# Installer Nginx et OpenSSL (pour le certificat)
RUN apt-get update && apt-get install -y nginx openssl 

# Supprime TOUS les fichiers de config parasites qui forcaient nginx a ecouter sur le port 80 (grosse galere a trouver)
RUN rm -f /etc/nginx/sites-enabled/default \
        /etc/nginx/conf.d/default.conf \
        /etc/nginx/sites-available/default

# Créer les dossiers nécessaires
RUN mkdir -p /run/nginx /etc/nginx/ssl /var/www/wordpress

# Copier la configuration Nginx dans le conteneur
COPY conf/nginx.conf /etc/nginx/conf.d/default.conf

# !!! GROSSE GALERE ICI !!! MODIF IMPORTANTE : Retire l'inclusion globale de conf.d/ (hors bloc http), puis la réinjecte proprement dans http {}
# Cela permet à nginx de charger notre conf SSL sans retomber sur les erreurs "listen 80 already in use"
RUN sed -i 's|include /etc/nginx/conf.d/\*\.conf;|# include removed to avoid duplicate loading|g' /etc/nginx/nginx.conf && \
    sed -i '/http {/a \    include /etc/nginx/conf.d/*.conf;' /etc/nginx/nginx.conf

# Générer un certificat auto-signé pour le domaine
ARG DOMAIN_NAME
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
-keyout /etc/nginx/ssl/website.key -out /etc/nginx/ssl/website.crt \
-subj "/C=FR/ST=Paris/L=Paris/O=42/OU=Inception/CN=${DOMAIN_NAME}"

# Exposer le port 443 (HTTPS)
EXPOSE 443

# Supprime tous les fichiers de config par défaut qui pourraient binder sur le port 80
RUN rm -rf /etc/nginx/http.d

# Lancer Nginx en mode non-démon (au premier plan)
CMD ["nginx", "-g", "daemon off;"]
