#!/bin/bash

p_root=$(cat /run/secrets/db_root_pass)
p_user=$(cat /run/secrets/db_user_pass)

if [ ! -d "/var/lib/mysql/$SQL_DATABASE" ]; then
    
    echo "Initializing MariaDB database..."
    service mariadb start
    
    sleep 5

    mariadb -e "CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;"
    mariadb -e "CREATE USER IF NOT EXISTS \`${SQL_USER}\`@'%' IDENTIFIED BY '${p_user}';"
    mariadb -e "GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO \`${SQL_USER}\`@'%';"

    mariadb -e "CREATE USER IF NOT EXISTS \`${SQL_USER}\`@'wordpress.srcs_inception' IDENTIFIED BY '${p_user}';"
    mariadb -e "GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO \`${SQL_USER}\`@'wordpress.srcs_inception';"
    
    mariadb -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${p_root}';"
    mariadb -e "FLUSH PRIVILEGES;"

    mysqladmin -u root -p"$p_root" shutdown
    
    echo "Database configured successfully!"
else
    echo "Database already configured. Skipping setup."
fi

echo "Starting MariaDB..."
exec mysqld_safe