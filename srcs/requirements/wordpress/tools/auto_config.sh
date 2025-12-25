#!/bin/bash

echo "Waiting for MariaDB to be ready..."
sleep 15 

p_user=$(cat /run/secrets/db_user_pass)
p_admin=$(cat /run/secrets/wp_admin_pass)
p_visitor=$(cat /run/secrets/wp_user_pass)


echo "Testing database connection..."
max_tries=40
count=0

# Test with both mariadb client AND wp-cli connectivity
until mariadb -h mariadb -u $SQL_USER -p$p_user $SQL_DATABASE -e "SELECT 1" &>/dev/null && \
      mariadb -h mariadb -P 3306 -u $SQL_USER -p$p_user $SQL_DATABASE -e "SELECT 1" &>/dev/null; do
    count=$((count + 1))
    if [ $count -gt $max_tries ]; then
        echo "ERROR: Could not connect to database after $max_tries attempts"
        echo "Debugging info:"
        echo "  Host: mariadb"
        echo "  User: $SQL_USER"
        echo "  Database: $SQL_DATABASE"
        echo "Checking if mariadb host resolves:"
        ping -c 2 mariadb || echo "Cannot ping mariadb"
        exit 1
    fi
    echo "Waiting for database connection... (attempt $count/$max_tries)"
    sleep 3
done
echo "Database connection successful!"

# Additional wait for MariaDB to be fully stable
echo "Waiting for MariaDB to stabilize..."
sleep 5

if [ ! -f /var/www/wordpress/wp-config.php ]; then
    echo "WordPress not configured. Starting setup..."

    if [ ! -f /var/www/wordpress/index.php ]; then
        echo "Downloading WordPress..."
        wp core download --allow-root
    else
        echo "WordPress files already present."
    fi

    echo "Creating wp-config.php..."
    
    # Try multiple times with wp config create
    wp_config_tries=5
    wp_config_count=0
    wp_config_success=false
    
    while [ $wp_config_count -lt $wp_config_tries ]; do
        wp_config_count=$((wp_config_count + 1))
        echo "Attempting to create wp-config.php (attempt $wp_config_count/$wp_config_tries)..."
        
        if wp config create \
            --dbname=$SQL_DATABASE \
            --dbuser=$SQL_USER \
            --dbpass=$p_user \
            --dbhost=mariadb:3306 \
            --allow-root \
            --force 2>&1; then
            wp_config_success=true
            break
        fi
        
        echo "Failed to create wp-config.php, waiting 5 seconds before retry..."
        sleep 5
    done
    
    if [ "$wp_config_success" = false ]; then
        echo "ERROR: Failed to create wp-config.php after $wp_config_tries attempts"
        echo "Trying manual connection test..."
        mariadb -h mariadb -P 3306 -u $SQL_USER -p$p_user $SQL_DATABASE -e "SHOW TABLES;" || echo "Manual test also failed"
        exit 1
    fi

    if [ ! -f /var/www/wordpress/wp-config.php ]; then
        echo "ERROR: wp-config.php file does not exist after creation"
        exit 1
    fi
    echo "wp-config.php created successfully!"

    echo "Installing WordPress..."
    wp core install \
        --url="https://$DOMAIN_NAME" \
        --title="$SITE_TITLE" \
        --admin_user=$ADMIN_USER \
        --admin_password=$p_admin \
        --admin_email=$ADMIN_EMAIL \
        --skip-email \
        --allow-root

    echo "Creating additional user..."
    wp user create \
        $USER1_LOGIN \
        $USER1_EMAIL \
        --role=author \
        --user_pass=$p_visitor \
        --allow-root

    echo "WordPress setup completed successfully!"
else
    echo "WordPress already configured."
    # Update site URL if needed
    wp option update home "https://$DOMAIN_NAME" --allow-root 2>/dev/null || true
    wp option update siteurl "https://$DOMAIN_NAME" --allow-root 2>/dev/null || true
fi

echo "Setting permissions..."
chown -R www-data:www-data /var/www/wordpress
chmod -R 755 /var/www/wordpress

echo "Starting PHP-FPM..."
exec /usr/sbin/php-fpm7.4 -F