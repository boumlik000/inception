HELLO , i mboumlik will explain to u how to u se inception from 42 with details:

1- Set up the environment from scratch 

    Before starting development, ensure you have the following installed:
        Required Software:
            - Docker Engine (version 20.10 or higher)
            - Docker Compose (version 1.29 or higher)
            - Make (GNU Make)
            - Git
        System Requirements:
            - Linux/Unix-based system or WSL2 on Windows
            - Minimum 2GB RAM available for containers
            - At least 10GB free disk space

        Installation Commands (Debian/Ubuntu):
            :: sudo apt-get update
            :: sudo apt-get install docker.io docker-compose
            :: sudo usermod -aG docker $USER
            :: sudo apt-get install make
        Verify Installation:
            :: docker --version
            :: docker-compose --version
            :: make --version

        Initial Configuration:
            a. Clone the Repository
                :: git clone <your-repo-url> inception
                :: cd inception
            b. Create the .env File and secrets folder
                *The .env file and  the secrets folder  contain all sensitive configuration and must be created manually. It should be located            at srcs/.env -- and for secrets in the root : clonedrepo/secrets
                :: touch srcs/.env
                :: mkdir secrets
                *this what u put inside .env and inside secrets :
                    **.env
                        # Domain Configuration
                        DOMAIN_NAME=your-login.42.fr
                        
                        # MariaDB Configuration
                        MYSQL_ROOT_PASSWORD=secure_root_password_here
                        MYSQL_DATABASE=wordpress
                        MYSQL_USER=wp_user
                        MYSQL_PASSWORD=secure_user_password_here

                        # WordPress Admin User
                        WP_ADMIN_USER=admin
                        WP_ADMIN_PASSWORD=secure_admin_password
                        WP_ADMIN_EMAIL=admin@example.com

                        # WordPress Regular User
                        WP_USER=regular_user
                        WP_USER_PASSWORD=secure_user_password
                        WP_USER_EMAIL=user@example.com

                        # WordPress Configuration
                        WP_TITLE=My Inception Site
                        WP_URL=https://your-login.42.fr
                    **secrets
                    touch db_root_pass.txt   db_user_pass.txt   wp_admin_pass.txt  wp_user_pass.txt
                    write(dont let new line at the end bc we gonna use this after in the mariadb/wordpress) 
                    inside db_root_pass.txt     => "pass_root_database"
                    inside db_user_pass.txt     => "pass_user_database"
                    inside wp_admin_pass.txt    => "pass_admin_wordpress"
                    inside wp_user_pass.txt     => "pass_user_wordpress"
                Important Security Notes:
                    Never commit the .env file or secrete folder to version control
                    Ensure .env and secrete folder is in your .gitignore
                    Use strong, unique passwords for production
                    Change all default values before deployment
            c. Configure Domain Name
                :: sudo echo "127.0.0.1 (your-login).42.fr" >> /etc/hosts 
            d. Set Up Volume Directories
                :: sudo mkdir -p /home/$USER/data/wordpress
                :: sudo mkdir -p /home/$USER/data/mariadb
                :: sudo chown -R $USER:$USER /home/$USER/data
                normally this will happend in the makefile but we will come to it later
                inception/
                ├── Makefile                    # Build automation
                ├── secrets                     #(not in git)
                │    |
                │    ├── db_root_pass.txt
                │    ├── db_user_pass.txt
                │    ├── wp_admin_pass.txt
                │    └── wp_user_pass.txt
                ├── srcs/
                │   ├── docker-compose.yml     # Container orchestration
                │   ├── .env                   # Environment variables (not in git)
                │   └── requirements/
                │       ├── mariadb/
                │       │   ├── Dockerfile     # MariaDB image definition
                │       │   ├── conf/
                │       │   │   └── 50-server.cnf
                │       │   └── tools/
                │       │       └── entrypoint.sh
                │       ├── nginx/
                │       │   ├── Dockerfile     # NGINX image definition
                │       │   ├── conf/
                │       │   │   └── nginx.conf
                │       │   └── tools/
                │       │       └── setup.sh
                │       └── wordpress/
                │           ├── Dockerfile     # WordPress image definition
                │           ├── conf/
                │           │   └── www.conf
                │           └── tools/
                │               └── entrypoint.sh
                └── README.md

2- building and lunching 
    
    USE makefile for building and lunching, since it have the right commands to run it .
    a. Build and start all services:
        :: "make" or "make all" or "make up"
            This command:
            - Reads the docker-compose.yml file
            - Builds custom images from Dockerfiles
            - Creates the Docker network
            - Creates volumes for persistent storage
            - Starts all containers in the background (named detached mode in docker)
            u can read the USER_DOC.md for more informations abt each command in the makefile : make down/stop/start/clean/fclean/re

3- container and volume manager +  identify where the project data is stored and how it persists
    a. container manager 
        :: "docker ps" -> view runing containers , + "-a" -> view all of them
        :: "docker inspect <container_name>" ->  get detailed container information
        :: "docker stats" -> shows the stat of each runing container (live)
        :: "docker top <container_name>" -> Check container processes
        :: "docker exec -it (container name) bash" -> open a bash inside a container
        :: "docker exec mariadb mysql -u root -p" -> run a command exemple 
        :: "docker-compose -f srcs/docker-compose.yml logs" -> view the logs of each service
        :: "docker-compose -f srcs/docker-compose.yml logs mariadb" -> view the logs of a specific service
        :: "docker-compose -f srcs/docker-compose.yml logs -f" ->view logs in real time(live)
        :: "docker-compose -f srcs/docker-compose.yml restart nginx" -> restarting a service
        :: "docker-compose -f srcs/docker-compose.yml restart " ->restarting all services
    b. volume manager
        Docker volumes provide persistent storage that survives container restarts and removals. The Inception project uses volumes for:
            .wordpress_volume: Stores WordPress files (/var/www/html) (inside container)
            .mariadb_volume: Stores database files (/var/lib/mysql) (inside container)
        :: "docker volume ls" -> list all volumes
        :: "docker volume inspect srcs_wordpress_data" -> volume informations
        :: "docker exec -it wordpress ls -la" ->go inside a container and view ls -la
        :: "docker volume rm srcs_wordpress_data" -> delete a volume
        :: "docker volume prune" -> delete all unused volumes