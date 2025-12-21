HELLO in this file ,I mboumlik will explain how u can use Inception project.
1- What services are provided in the stak :
    * Nginx : web server with TLS(ssl increption)
        - Configured with TLSv1.3
        - Act as a reverse Proxy to other services
        - Serve ur website securely on HTTPS
 
    * Wordpress : Content management system 
        - website and a blog platform
        - accessible via web browser
        - connected to Mariadb databse
 
    * Mariadb : Database server
        - stores all Wordpress Data
        - secure database using user authontification
        - presistent storage using docker volumes

2- How to start and stop the project :
    a:  To start the project :
        - first create the paths for the volumes : 
            * mkdir -p /home/(hostname)/data/worpress
            * mkdir /home/(hostname)/data/mariadb
        - to start all service : make
        - or manualy : docker compose -f ./srcs/docker-compose.yml up -d --build
        ::The -d flag runs containers in detached mode (background).

        ** First Launch: The first time you start the project, Docker will:
            - Build all custom images (this may take a few minutes)
            - Create volumes for persistent data
            - Initialize the database
            - Set up the WordPress installation

    b:  To stop the project :
        - make stop
        - or manually :docker-compose -f ./srcs/docker-compose.yml stop
        :: its highly recomended that if u want to run back ur containers: make start

    c: for complete cleanup:
        - make fclean
        ::Warning: This will delete all data including your database and WordPress files!

    d: to restart all services:
        - make re
        ::This performs a clean restart (stops, cleans, and starts fresh)

3- How to Access website and administrator panel :
    - open ur browser and navigate to https://your-domain.42.fr
    ::Replace your-domain with your actual domain name (ur login)
    ::Note: You may see a security warning on first access because the SSL certificate is self-signed. This is normal for development. Click "Advanced" and proceed to the site.
    - to access the wordpress admin dashboard : https://your-domain.42.fr/wp-admin
    ::You will be prompted to log in with your WordPress admin password

4- Locate and manage credentials :
    - All credentials are stored in the .env file located in the srcs directory (Emails , Names)
    - All passwords are stored in the secret folder , to read the password : cat secrets/wp_admin_pass.txt (ex)
    :: u can change the password by modifying the files in secret , also u can change the email or name from .env file (ex : ADMIN_USER=mboumlik ==> ADMIN_USER=ad_ad_user)
    
5-  Check that the services are running correctly :
    - run : docker ps 
    :: u shoud see three container : nginx(port 443) , wordpress(port 9000) , mariadb (port 3306)
    - check individual service status : 
        ** docker compose ps nginx
        ** docker compose ps mariadb
        ** docker compose ps wordpress
    - to see whats hapening inside a container 
        ::for all services :
            ** docker compose logs
        ::for individuals :
            ** docker-compose logs nginx
            ** docker-compose logs wordpress
            ** docker-compose logs mariadb
    -  ::follow logs for a real time :
        docker-compose logs -f 
    - test your Nginx :
        curl -k https://localhost
        ::You should receive HTML content from your WordPress site
    - test database container :
        :: to inter maria db container :
            docker exec -it mariadb bash
        :: to connect with data base :
            mysql -u root -p ::Enter your MYSQL_ROOT_PASSWORD when prompted.(from secrets folder)
    - test with your worpress
        docker exec -it wordpress ps aux | grep php ::You should see PHP-FPM processes running
    - verify volumes 
        :: check volumes exist 
            docker volume ls ::You should see srcs_mariadb_data srcs_wordpress_data

end .
