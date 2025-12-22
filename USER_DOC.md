# User Documentation - Inception Project

Hello! In this file, I (mboumlik) will explain how you can use the Inception project.

## 1. What Services are Provided in the Stack

### Nginx - Web Server with TLS (SSL Encryption)
- Configured with TLSv1.3
- Acts as a reverse proxy to other services
- Serves your website securely on HTTPS

### WordPress - Content Management System
- Website and blog platform
- Accessible via web browser
- Connected to MariaDB database

### MariaDB - Database Server
- Stores all WordPress data
- Secure database using user authentication
- Persistent storage using Docker volumes

## 2. How to Start and Stop the Project

### a. To Start the Project

**First, create the paths for the volumes:**
```bash
mkdir -p /home/(hostname)/data/wordpress
mkdir -p /home/(hostname)/data/mariadb
```

**To start all services:**
```bash
make
```

**Or manually:**
```bash
docker-compose -f ./srcs/docker-compose.yml up -d --build
```

> The `-d` flag runs containers in detached mode (background).

#### First Launch

The first time you start the project, Docker will:
- Build all custom images (this may take a few minutes)
- Create volumes for persistent data
- Initialize the database
- Set up the WordPress installation

### b. To Stop the Project

```bash
make stop
```

**Or manually:**
```bash
docker-compose -f ./srcs/docker-compose.yml stop
```

> It's highly recommended that if you want to run back your containers, use: `make start`

### c. For Complete Cleanup

```bash
make fclean
```

> ⚠️ **Warning:** This will delete all data including your database and WordPress files!

### d. To Restart All Services

```bash
make re
```

> This performs a clean restart (stops, cleans, and starts fresh)

## 3. How to Access Website and Administrator Panel

### Access Your Website

Open your browser and navigate to:
```
https://your-domain.42.fr
```

> Replace `your-domain` with your actual domain name (your login)

> **Note:** You may see a security warning on first access because the SSL certificate is self-signed. This is normal for development. Click "Advanced" and proceed to the site.

### Access WordPress Admin Dashboard

Navigate to:
```
https://your-domain.42.fr/wp-admin
```

> You will be prompted to log in with your WordPress admin password

## 4. Locate and Manage Credentials

- All credentials are stored in the `.env` file located in the `srcs` directory (Emails, Names)
- All passwords are stored in the `secrets` folder

**To read a password:**
```bash
cat secrets/wp_admin_pass.txt
```

**To change credentials:**
- Change passwords by modifying the files in the `secrets` folder
- Change emails or names in the `.env` file

Example:
```env
ADMIN_USER=mboumlik  # Change to
ADMIN_USER=ad_ad_user
```

## 5. Check That Services are Running Correctly

### Check Running Containers

```bash
docker ps
```

> You should see three containers:
> - `nginx` (port 443)
> - `wordpress` (port 9000)
> - `mariadb` (port 3306)

### Check Individual Service Status

```bash
docker-compose ps nginx
docker-compose ps mariadb
docker-compose ps wordpress
```

### View Container Logs

**For all services:**
```bash
docker-compose logs
```

**For individual services:**
```bash
docker-compose logs nginx
docker-compose logs wordpress
docker-compose logs mariadb
```

**Follow logs in real-time:**
```bash
docker-compose logs -f
```

### Test Your Nginx

```bash
curl -k https://localhost
```

> You should receive HTML content from your WordPress site

### Test Database Container

**Enter MariaDB container:**
```bash
docker exec -it mariadb bash
```

**Connect to database:**
```bash
mysql -u root -p
```

> Enter your `MYSQL_ROOT_PASSWORD` when prompted (from secrets folder)

### Test WordPress

```bash
docker exec -it wordpress ps aux | grep php
```

> You should see PHP-FPM processes running

### Verify Volumes

**Check volumes exist:**
```bash
docker volume ls
```

> You should see:
> - `srcs_mariadb_data`
> - `srcs_wordpress_data`

---

**End.**