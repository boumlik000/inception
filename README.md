# Inception

*This project has been created as part of the 42 curriculum by mboumlik.*

## Description

Inception is a system administration project that focuses on containerization using Docker. The goal is to set up a small infrastructure composed of different services following specific rules, all orchestrated using Docker Compose. This project provides hands-on experience with virtualization, containerization, networking, and infrastructure management.

The infrastructure consists of multiple Docker containers, each running a specific service (NGINX, WordPress, MariaDB, etc.), all configured to work together seamlessly. Each service runs in its own dedicated container, built from either the penultimate stable version of Alpine or Debian, using custom Dockerfiles.

## Instructions

### Prerequisites

- Docker
- Docker Compose
- Make
- A virtual machine (recommended for 42 project compliance)

### Installation & Compilation

1. Clone the repository:
```bash
git clone <repository-url>
cd inception
```

2. Set up your environment variables:
```bash
# Create a .env file in the srcs directory with required variables
# See .env.example for reference
```

3. Build and start the infrastructure:
```bash
make
```

### Available Commands

- `make` or `make all` - Build and start all containers
- `make up` - Start all containers and build images
- `make down` - Stop and delete all containers / network 
- `make clean` - Stop and remove containers
- `make fclean` - Complete cleanup (containers, images, volumes)
- `make re` - Rebuild everything from scratch
- `make logs` - View logs from all containers
- `make ps` - List running containers

### Access

Once running, the services will be available at:
- NGINX (WordPress): `https://mboumlik.42.fr`
- Adminer (Database Management): `https://mboumlik.42.fr:8080` (if implemented)

> **Note**: You must configure your `/etc/hosts` file to point `mboumlik.42.fr` to `127.0.0.1` or your VM's IP address.

## Project Description

### Docker Usage

This project leverages Docker to create an isolated, reproducible infrastructure. Each service runs in its own container, ensuring separation of concerns and easy scalability. Docker Compose orchestrates these containers, managing their dependencies, networking, and volumes.

**Key Docker components used:**
- **Dockerfiles**: Custom images built from Alpine/Debian base images
- **Docker Compose**: Service orchestration and configuration
- **Docker Networks**: Custom bridge network for inter-container communication
- **Docker Volumes**: Persistent data storage for database and WordPress files

### Sources Included

The project includes the following main directories:
- `srcs/requirements/`: Contains Dockerfiles and configurations for each service
  - `nginx/`: Web server configuration and SSL setup
  - `wordpress/`: WordPress installation with PHP-FPM
  - `mariadb/`: Database server configuration
  - Additional services as required
- `srcs/docker-compose.yml`: Service orchestration configuration
- `srcs/.env`: Environment variables (not tracked in Git)
- `Makefile`: Build automation

### Design Choices

**Architecture**: Each service runs in a dedicated container following microservices principles. Containers communicate through a custom Docker network, with NGINX serving as the entry point. Persistent data is stored in Docker volumes to ensure data survives container restarts.

**Security**: TLSv1.2 or TLSv1.3 is enforced on NGINX. Sensitive information is managed through environment variables stored in a `.env` file (not committed to the repository). Container images are built from official stable base images to ensure security patches.

**Performance**: PHP-FPM is used with NGINX for efficient WordPress execution. MariaDB is configured with appropriate buffer sizes and connection limits for optimal performance.

### Virtual Machines vs Docker

| Aspect | Virtual Machines | Docker |
|--------|-----------------|---------|
| **Architecture** | Full OS with hypervisor | Shared kernel, isolated processes |
| **Resource Usage** | Heavy (GBs of RAM, significant CPU) | Lightweight (MBs of RAM, minimal CPU) |
| **Startup Time** | Minutes | Seconds |
| **Isolation** | Complete isolation (hardware level) | Process-level isolation |
| **Portability** | Limited (hardware dependent) | Highly portable (runs anywhere Docker runs) |
| **Use Case** | Complete OS isolation, legacy apps | Microservices, modern applications |

**For this project**: Docker is chosen for its lightweight nature, fast deployment, and ability to easily orchestrate multiple services.

### Secrets vs Environment Variables

| Aspect | Secrets | Environment Variables |
|--------|---------|----------------------|
| **Security** | Encrypted at rest and in transit | Plain text, visible in container inspect |
| **Access Control** | Fine-grained permissions | Available to entire container |
| **Rotation** | Can be rotated without redeployment | Requires container restart |
| **Best For** | Passwords, API keys, certificates | Non-sensitive configuration |
| **Docker Support** | Docker Swarm secrets, third-party tools | Native support in Docker Compose |

**For this project**: Environment variables are used (via `.env` file) as the project doesn't require Docker Swarm. However, the `.env` file is excluded from Git to prevent credential exposure.

### Docker Network vs Host Network

| Aspect | Docker Network | Host Network |
|--------|----------------|--------------|
| **Isolation** | Containers have isolated network stack | Container shares host's network stack |
| **Port Mapping** | Required (port forwarding) | Direct access to host ports |
| **Security** | Better isolation between containers | Direct exposure to host network |
| **DNS** | Built-in DNS for service discovery | Uses host's DNS |
| **Performance** | Slight overhead from NAT | Minimal overhead (native performance) |

**For this project**: A custom Docker bridge network is used to provide isolation while allowing containers to communicate using service names as hostnames (e.g., `mariadb`, `wordpress`).

### Docker Volumes vs Bind Mounts

| Aspect | Docker Volumes | Bind Mounts |
|--------|----------------|-------------|
| **Management** | Managed by Docker | Managed by host filesystem |
| **Location** | Docker's storage directory | Any host path |
| **Portability** | Highly portable across hosts | Host-path dependent |
| **Performance** | Optimized by Docker | Native filesystem performance |
| **Backup** | Docker volume commands | Standard filesystem tools |
| **Use Case** | Production data persistence | Development, config files |

**For this project**: Docker volumes are used for persistent data (database, WordPress files) as required by the subject. This ensures data persistence across container restarts and provides better portability and management.

## Resources

### Documentation & References

- [Docker Official Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [WordPress Docker Image](https://hub.docker.com/_/wordpress)
- [MariaDB Documentation](https://mariadb.org/documentation/)
- [Alpine Linux](https://alpinelinux.org/)
- [Debian](https://www.debian.org/)
- [SSL/TLS Best Practices](https://wiki.mozilla.org/Security/Server_Side_TLS)

### Tutorials

- [Docker Networking Deep Dive](https://docs.docker.com/network/)
- [Docker Volumes Tutorial](https://docs.docker.com/storage/volumes/)
- [Setting up NGINX with SSL](https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-nginx-in-ubuntu-18-04)
- [WordPress with Docker](https://www.docker.com/blog/how-to-use-the-official-nginx-docker-image/)

### AI Usage

**Tasks where AI was used:**
- **Dockerfile optimization**: Assistance with multi-stage builds and layer optimization
- **Docker Compose syntax**: Verification of service configuration and dependency ordering
- **Shell scripting**: Entry point script logic and error handling patterns
- **NGINX configuration**: SSL/TLS configuration syntax and best practices
- **README structure**: Formatting and organization of documentation
- **Troubleshooting**: Debugging container networking and volume permission issues

**Parts of the project created with AI assistance:**
- Initial Dockerfile templates (heavily modified for project requirements)
- Docker Compose service definitions structure
- NGINX configuration snippets for SSL
- MariaDB initialization scripts structure
- Documentation and comments

**Note**: All code was reviewed, tested, and modified to meet project requirements and personal understanding. AI served as a learning tool and reference, not a complete solution generator.

---

**Author**: [boumlik_mohamed/mboumlik]  
**Project**: Inception  
**School**: 1337  
**Date**: 12/24/2025
