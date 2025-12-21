# DEVELOPER DOCUMENTATION - Inception Project

## Table of Contents

1. [Environment Setup](#environment-setup)
2. [Project Structure](#project-structure)
3. [Building and Launching](#building-and-launching)
4. [Container Management](#container-management)
5. [Volume Management](#volume-management)
6. [Data Persistence](#data-persistence)
7. [Troubleshooting](#troubleshooting)

---

## Environment Setup

### Prerequisites

Before starting development, ensure you have the following installed:

**Required Software:**
- Docker Engine (version 20.10 or higher)
- Docker Compose (version 1.29 or higher)
- Make (GNU Make)
- Git

**System Requirements:**
- Linux/Unix-based system or WSL2 on Windows
- Minimum 2GB RAM available for containers
- At least 10GB free disk space

**Installation Commands (Debian/Ubuntu):**

```bash
# Update package index
sudo apt-get update

# Install Docker
sudo apt-get install docker.io docker-compose

# Add your user to docker group (to run without sudo)
sudo usermod -aG docker $USER

# Install make if not present
sudo apt-get install make

# Log out and back in for group changes to take effect
```

**Verify Installation:**

```bash
docker --version
docker-compose --version
make --version
```

### Initial Configuration

#### 1. Clone the Repository

```bash
git clone <your-repo-url> inception
cd inception
```

#### 2. Create the .env File

The `.env` file contains all sensitive configuration and must be created manually. It should be located at `srcs/.env`.

**Create the file:**

```bash
touch srcs/.env
```

**Populate with the following template:**

```bash
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

**Important Security Notes:**
- Never commit the `.env` file to version control
- Ensure `.env` is in your `.gitignore`
- Use strong, unique passwords for production
- Change all default values before deployment

#### 3. Configure Domain Name

Add your domain to `/etc/hosts` for local development:

```bash
sudo echo "127.0.0.1 your-login.42.fr" >> /etc/hosts
```

Replace `your-login.42.fr` with your actual domain name.

#### 4. Set Up Volume Directories

The project uses bind mounts or named volumes. If using bind mounts, create the directories:

```bash
sudo mkdir -p /home/$USER/data/wordpress
sudo mkdir -p /home/$USER/data/mariadb
sudo chown -R $USER:$USER /home/$USER/data
```

---

## Project Structure

```
inception/
├── Makefile                    # Build automation
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

---

## Building and Launching

### Using the Makefile

The Makefile provides convenient commands for common operations:

**View all available commands:**

```bash
make help
```

**Build and start all services:**

```bash
make
# or
make all
```

This command:
1. Reads the docker-compose.yml file
2. Builds custom images from Dockerfiles
3. Creates the Docker network
4. Creates volumes for persistent storage
5. Starts all containers in detached mode

**Behind the scenes, it runs:**

```bash
docker-compose -f srcs/docker-compose.yml up -d --build
```

### Manual Docker Compose Commands

**Build images without starting:**

```bash
docker-compose -f srcs/docker-compose.yml build
```

**Build a specific service:**

```bash
docker-compose -f srcs/docker-compose.yml build nginx
docker-compose -f srcs/docker-compose.yml build wordpress
docker-compose -f srcs/docker-compose.yml build mariadb
```

**Start containers (after building):**

```bash
docker-compose -f srcs/docker-compose.yml up -d
```

**Start in foreground (see logs):**

```bash
docker-compose -f srcs/docker-compose.yml up
```

**Force rebuild (ignore cache):**

```bash
docker-compose -f srcs/docker-compose.yml build --no-cache
docker-compose -f srcs/docker-compose.yml up -d
```

### Stopping the Project

**Stop containers (keep data):**

```bash
make stop
# or
docker-compose -f srcs/docker-compose.yml stop
```

**Stop and remove containers:**

```bash
make down
# or
docker-compose -f srcs/docker-compose.yml down
```

### Complete Cleanup

**Remove everything (containers, volumes, networks):**

```bash
make fclean
```

This runs:

```bash
docker-compose -f srcs/docker-compose.yml down -v
docker system prune -af --volumes
```

**Warning:** This deletes all project data!

### Rebuild from Scratch

```bash
make re
```

This performs: `make fclean` → `make all`

---

## Container Management

### Listing Containers

**View running containers:**

```bash
docker ps
```

**View all containers (including stopped):**

```bash
docker ps -a
```

**Filter by project:**

```bash
docker ps --filter "name=srcs"
```

### Inspecting Containers

**Get detailed container information:**

```bash
docker inspect <container_name>
```

**View container resource usage:**

```bash
docker stats
```

**Check container processes:**

```bash
docker top <container_name>
```

### Accessing Containers

**Open a shell inside a container:**

```bash
docker exec -it mariadb bash
docker exec -it wordpress bash
docker exec -it nginx bash
```

**Run a single command:**

```bash
docker exec mariadb mysql -u root -p
docker exec wordpress wp --info --allow-root
docker exec nginx nginx -t
```

### Viewing Logs

**All services:**

```bash
docker-compose -f srcs/docker-compose.yml logs
```

**Specific service:**

```bash
docker-compose -f srcs/docker-compose.yml logs nginx
docker-compose -f srcs/docker-compose.yml logs wordpress
docker-compose -f srcs/docker-compose.yml logs mariadb
```

**Follow logs in real-time:**

```bash
docker-compose -f srcs/docker-compose.yml logs -f
```

**Last 50 lines:**

```bash
docker-compose -f srcs/docker-compose.yml logs --tail=50
```

**With timestamps:**

```bash
docker-compose -f srcs/docker-compose.yml logs -t
```

### Restarting Services

**Restart a single service:**

```bash
docker-compose -f srcs/docker-compose.yml restart nginx
```

**Restart all services:**

```bash
docker-compose -f srcs/docker-compose.yml restart
```

---

## Volume Management

### Understanding Volumes

Docker volumes provide persistent storage that survives container restarts and removals. The Inception project uses volumes for:

- **wordpress_volume**: Stores WordPress files (`/var/www/html`)
- **mariadb_volume**: Stores database files (`/var/lib/mysql`)

### Listing Volumes

**All volumes:**

```bash
docker volume ls
```

**Filter project volumes:**

```bash
docker volume ls --filter "name=srcs"
```

### Inspecting Volumes

**Detailed volume information:**

```bash
docker volume inspect srcs_wordpress_volume
docker volume inspect srcs_mariadb_volume
```

**Example output:**

```json
[
    {
        "CreatedAt": "2024-01-15T10:30:00Z",
        "Driver": "local",
        "Labels": {
            "com.docker.compose.project": "srcs",
            "com.docker.compose.volume": "wordpress_volume"
        },
        "Mountpoint": "/var/lib/docker/volumes/srcs_wordpress_volume/_data",
        "Name": "srcs_wordpress_volume",
        "Scope": "local"
    }
]
```

The `Mountpoint` shows where data is physically stored on the host.

### Accessing Volume Data

**Access data from host (requires root):**

```bash
sudo ls -la /var/lib/docker/volumes/srcs_wordpress_volume/_data
sudo ls -la /var/lib/docker/volumes/srcs_mariadb_volume/_data
```

**Access via container:**

```bash
docker exec -it wordpress ls -la /var/www/html
docker exec -it mariadb ls -la /var/lib/mysql
```

### Backing Up Volumes

**Backup WordPress files:**

```bash
docker run --rm \
  -v srcs_wordpress_volume:/source \
  -v $(pwd):/backup \
  alpine tar czf /backup/wordpress-backup.tar.gz -C /source .
```

**Backup MariaDB database:**

```bash
docker exec mariadb mysqldump -u root -p${MYSQL_ROOT_PASSWORD} \
  --all-databases > mariadb-backup.sql
```

### Restoring Volumes

**Restore WordPress files:**

```bash
docker run --rm \
  -v srcs_wordpress_volume:/target \
  -v $(pwd):/backup \
  alpine tar xzf /backup/wordpress-backup.tar.gz -C /target
```

**Restore MariaDB database:**

```bash
docker exec -i mariadb mysql -u root -p${MYSQL_ROOT_PASSWORD} \
  < mariadb-backup.sql
```

### Removing Volumes

**Remove specific volume:**

```bash
docker volume rm srcs_wordpress_volume
docker volume rm srcs_mariadb_volume
```

**Warning:** This permanently deletes all data!

**Remove unused volumes:**

```bash
docker volume prune
```

---

## Data Persistence

### How Data Persists

The project ensures data persistence through Docker volumes:

1. **Named Volumes** (defined in docker-compose.yml):
   ```yaml
   volumes:
     wordpress_volume:
       driver: local
     mariadb_volume:
       driver: local
   ```

2. **Volume Mounts** (per service):
   ```yaml
   services:
     mariadb:
       volumes:
         - mariadb_volume:/var/lib/mysql
     wordpress:
       volumes:
         - wordpress_volume:/var/www/html
   ```

### Data Lifecycle

**Container lifecycle vs. Data lifecycle:**

| Action | Containers | Volumes |
|--------|-----------|---------|
| `docker-compose stop` | Stopped | Preserved |
| `docker-compose down` | Removed | Preserved |
| `docker-compose down -v` | Removed | **Removed** |
| Container crash | Restarted | Preserved |
| System reboot | Stopped | Preserved |

### Data Location on Host

**Default Docker volume path:**

```bash
/var/lib/docker/volumes/<project>_<volume_name>/_data
```

**For this project:**

- WordPress: `/var/lib/docker/volumes/srcs_wordpress_volume/_data`
- MariaDB: `/var/lib/docker/volumes/srcs_mariadb_volume/_data`

### Bind Mounts (Alternative)

If using bind mounts instead of named volumes:

```yaml
volumes:
  - /home/$USER/data/wordpress:/var/www/html
  - /home/$USER/data/mariadb:/var/lib/mysql
```

Data is stored directly in host directories, easier to access but less portable.

---

## Troubleshooting

### Build Issues

**Problem: Build fails with "no space left on device"**

```bash
# Clean up Docker system
docker system prune -a --volumes

# Remove old images
docker image prune -a
```

**Problem: Build uses cached layers incorrectly**

```bash
# Force rebuild without cache
docker-compose -f srcs/docker-compose.yml build --no-cache
```

### Network Issues

**Problem: Containers can't communicate**

```bash
# Check network exists
docker network ls

# Inspect network
docker network inspect srcs_inception_network

# Verify containers are on the network
docker inspect <container> | grep NetworkMode
```

**Problem: Port already in use**

```bash
# Find what's using port 443
sudo lsof -i :443

# Kill the process or change port in docker-compose.yml
```

### Volume Issues

**Problem: Permission denied in volumes**

```bash
# Fix permissions inside container
docker exec -it wordpress chown -R www-data:www-data /var/www/html
docker exec -it mariadb chown -R mysql:mysql /var/lib/mysql
```

**Problem: Data not persisting**

```bash
# Verify volumes are mounted
docker inspect <container> | grep -A 10 Mounts

# Check volume exists
docker volume inspect <volume_name>
```

### Debugging Commands

**Check container health:**

```bash
docker inspect --format='{{.State.Health.Status}}' <container>
```

**View last 100 log lines:**

```bash
docker logs --tail=100 <container>
```

**Test database connection:**

```bash
docker exec mariadb mysqladmin -u root -p${MYSQL_ROOT_PASSWORD} ping
```

**Test NGINX configuration:**

```bash
docker exec nginx nginx -t
```

**Check WordPress installation:**

```bash
docker exec wordpress wp core is-installed --allow-root
```

---

## Development Workflow

### Typical Development Cycle

1. Make changes to Dockerfiles or configuration
2. Rebuild specific service: `docker-compose build <service>`
3. Restart service: `docker-compose up -d <service>`
4. Test changes: View logs and access services
5. Debug if needed: `docker exec -it <container> bash`

### Hot Reload for Configuration Changes

Some configurations can be reloaded without rebuilding:

```bash
# Reload NGINX config
docker exec nginx nginx -s reload

# Restart PHP-FPM
docker exec wordpress kill -USR2 1
```

### Testing Individual Components

**Test MariaDB:**

```bash
docker exec -it mariadb mysql -u root -p
```

**Test WordPress CLI:**

```bash
docker exec wordpress wp --info --allow-root
```

**Test NGINX:**

```bash
curl -k https://localhost
```

---

## Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [WordPress CLI Commands](https://developer.wordpress.org/cli/commands/)
- [MariaDB Documentation](https://mariadb.org/documentation/)
- [NGINX Documentation](https://nginx.org/en/docs/)