# Developer Documentation - Inception Project

Hello! I'm mboumlik and I'll explain how to use Inception from 42 with details.

## 1. Set up the environment from scratch

Before starting development, ensure you have the following installed:

### Required Software
- Docker Engine (version 20.10 or higher)
- Docker Compose (version 1.29 or higher)
- Make (GNU Make)
- Git

### System Requirements
- Linux/Unix-based system or WSL2 on Windows
- Minimum 2GB RAM available for containers
- At least 10GB free disk space

### Installation Commands (Debian/Ubuntu)

```bash
sudo apt-get update
sudo apt-get install docker.io docker-compose
sudo usermod -aG docker $USER
sudo apt-get install make
```

### Verify Installation

```bash
docker --version
docker-compose --version
make --version
```

## Initial Configuration

### a. Clone the Repository

```bash
git clone <your-repo-url> inception
cd inception
```

### b. Create the .env File and secrets folder

The `.env` file and the `secrets` folder contain all sensitive configuration and must be created manually. It should be located at `srcs/.env` and for secrets in the root: `clonedrepo/secrets`

```bash
touch srcs/.env
mkdir secrets
```

#### .env file contents

```env
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
```

#### secrets folder setup

```bash
touch secrets/db_root_pass.txt
touch secrets/db_user_pass.txt
touch secrets/wp_admin_pass.txt
touch secrets/wp_user_pass.txt
```

**Important:** Write passwords without a newline at the end, as we'll use these in MariaDB/WordPress:

- `db_root_pass.txt` → `pass_root_database`
- `db_user_pass.txt` → `pass_user_database`
- `wp_admin_pass.txt` → `pass_admin_wordpress`
- `wp_user_pass.txt` → `pass_user_wordpress`

#### Important Security Notes

- Never commit the `.env` file or `secrets` folder to version control
- Ensure `.env` and `secrets` folder are in your `.gitignore`
- Use strong, unique passwords for production
- Change all default values before deployment

### c. Configure Domain Name

```bash
sudo echo "127.0.0.1 (your-login).42.fr" >> /etc/hosts
```

### d. Set Up Volume Directories

```bash
sudo mkdir -p /home/$USER/data/wordpress
sudo mkdir -p /home/$USER/data/mariadb
sudo chown -R $USER:$USER /home/$USER/data
```

**Note:** Normally this will happen in the Makefile, but we'll come to it later.

## Project Structure

```
inception/
├── Makefile                    # Build automation
├── secrets/                    # (not in git)
│   ├── db_root_pass.txt
│   ├── db_user_pass.txt
│   ├── wp_admin_pass.txt
│   └── wp_user_pass.txt
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
```

## 2. Building and Launching

Use Makefile for building and launching, since it has the right commands to run it.

### a. Build and start all services

```bash
make
# or
make all
# or
make up
```

This command:
- Reads the `docker-compose.yml` file
- Builds custom images from Dockerfiles
- Creates the Docker network
- Creates volumes for persistent storage
- Starts all containers in the background (named detached mode in Docker)

You can read the `USER_DOC.md` for more information about each command in the Makefile: `make down/stop/start/clean/fclean/re`

## 3. Container and Volume Manager + Identify Where Project Data is Stored

### a. Container Manager

**View running containers:**
```bash
docker ps
docker ps -a  # View all containers
```

**Get detailed container information:**
```bash
docker inspect <container_name>
```

**Show stats of each running container (live):**
```bash
docker stats
```

**Check container processes:**
```bash
docker top <container_name>
```

**Open a bash inside a container:**
```bash
docker exec -it <container_name> bash
```

**Run a command example:**
```bash
docker exec mariadb mysql -u root -p
```

**View logs:**
```bash
# All services
docker-compose -f srcs/docker-compose.yml logs

# Specific service
docker-compose -f srcs/docker-compose.yml logs mariadb

# Real-time logs (live)
docker-compose -f srcs/docker-compose.yml logs -f
```

**Restart services:**
```bash
# Specific service
docker-compose -f srcs/docker-compose.yml restart nginx

# All services
docker-compose -f srcs/docker-compose.yml restart
```

### b. Volume Manager

Docker volumes provide persistent storage that survives container restarts and removals. The Inception project uses volumes for:

- **wordpress_volume:** Stores WordPress files (`/var/www/html` inside container)
- **mariadb_volume:** Stores database files (`/var/lib/mysql` inside container)

**List all volumes:**
```bash
docker volume ls
```

**Volume information:**
```bash
docker volume inspect srcs_wordpress_data
```

**Go inside a container and view ls -la:**
```bash
docker exec -it wordpress ls -la
```

**Delete a volume:**
```bash
docker volume rm srcs_wordpress_data
```

**Delete all unused volumes:**
```bash
docker volume prune
```