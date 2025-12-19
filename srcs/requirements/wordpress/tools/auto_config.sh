#!/bin/bash

sleep 10

p_user=$(cat /run/secrets/db_user_pass)
p_admin=$(cat /run/secrets/wp_admin_pass)
p_visitor=$(cat /run/secrets/wp_user_pass)


if [ ! -f /var/www/wordpress/wp-config.php ]; then

	wp core download --allow-root

	wp config create \
	--dbname=$SQL_DATABASE \
	--dbuser=$SQL_USER \
	--dbpass=$p_user \
	--dbhost=mariadb \
	--allow-root

	wp core install \
	--url=$DOMAIN_NAME \
	--title=$SITE_TITLE \
	--admin_user=$ADMIN_USER \
	--admin_password=$p_admin \
	--admin_email=$ADMIN_EMAIL \
	--allow-root

	wp user create \
	$USER1_LOGIN \
	$USER1_EMAIL \
	--role=author \
	--user_pass=$p_visitor \
	--allow-root
fi

exec /usr/sbin/php-fpm7.4 -F
