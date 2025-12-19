FROM debian:bullseye

RUN apt-get update && apt-get install -y mariadb-server

RUN mkdir -p /var/run/mysqld \
	  && chown -R mysql:mysql /var/run/mysqld \
	  && chmod 777  /var/run/mysqld

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

COPY tools/init_db.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/init_db.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/init_db.sh"]
