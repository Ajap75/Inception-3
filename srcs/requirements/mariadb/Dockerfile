# ==========================================================================
# Dockerfile MariaDB — Projet Inception (42)
# Construction manuelle et sécurisée d'un conteneur MariaDB à partir de Debian
# ==========================================================================

FROM debian:bookworm

ARG MYSQL_DATABASE
ARG MYSQL_USER
ARG MYSQL_PASSWORD
ENV MYSQL_DATABASE=${MYSQL_DATABASE}
ENV MYSQL_USER=${MYSQL_USER}
ENV MYSQL_PASSWORD=${MYSQL_PASSWORD}

RUN apt-get update && apt-get install -y mariadb-server mariadb-client

RUN mysql_install_db --user=mysql --datadir=/var/lib/mysql

RUN chown -R mysql:mysql /var/lib/mysql

RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld

RUN printf '[mysqld]\nbind-address=0.0.0.0\n' > /etc/mysql/mariadb.conf.d/bind_all.cnf

# --------------------------
# On copie init_db.sh et on donne les droits
# --------------------------
COPY tools/init_db.sh /init_db.sh
RUN chmod +x /init_db.sh

# --------------------------
# USER mysql à partir d'ici (optionnel, tu peux le laisser si tu veux, mais pas obligatoire car ENTRYPOINT le lancera en root puis passera en USER mysql si tu fais exec mysqld)
# --------------------------
# USER mysql

VOLUME /var/lib/mysql
EXPOSE 3306

# --------------------------
# Lancement du script d'init au démarrage (et seulement au démarrage du conteneur)
# --------------------------
ENTRYPOINT ["/init_db.sh"]
