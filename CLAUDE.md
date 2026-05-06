# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

DevStack is a Docker-based local development environment supporting multiple PHP versions (7.4, 8.2, 8.4), MySQL 5.7, MySQL 8, PostgreSQL 16, phpMyAdmin, and pgAdmin — all orchestrated via `docker-compose.yml` and managed through `devstack.sh`.

## Common Commands

All management goes through `devstack.sh` (or the `devstack` shell alias if configured):

```bash
./devstack.sh start          # Start all containers
./devstack.sh stop           # Stop all containers
./devstack.sh restart        # Restart all containers
./devstack.sh build          # Rebuild images and start
./devstack.sh status         # Show container status
./devstack.sh logs           # Stream logs from all services
./devstack.sh info           # Show all service URLs and mounted projects
./devstack.sh clearcache     # Clear PHP OpCache across containers
./devstack.sh clean          # DESTRUCTIVE: remove all containers and volumes
```

**Container access:**

```bash
./devstack.sh php74          # Shell into PHP 7.4 container
./devstack.sh php82          # Shell into PHP 8.2 container
./devstack.sh php84          # Shell into PHP 8.4 container
./devstack.sh mysql57        # MySQL 5.7 CLI
./devstack.sh mysql84        # MySQL 8.4 CLI
./devstack.sh postgres       # PostgreSQL CLI
```

**Project mounting:**

```bash
./devstack.sh mount <path> <php-version> [name]          # Mount external project
./devstack.sh mount <path> <php-version> [name] laravel  # Mount Laravel project (serves from public/)
./devstack.sh unmount <php-version> [name]               # Remove mounted project
./devstack.sh mounts [php-version]                       # List mounted projects
```

## Architecture

### Services and Ports (configured via `.env`)

| Service      | Default Port | Notes                              |
| ------------ | ------------ | ---------------------------------- |
| PHP 7.4      | 8074         | Apache, Xdebug 3.1.6               |
| PHP 8.2      | 8082         | Apache, Xdebug 3.3.2               |
| PHP 8.4      | 8084         | Apache, Xdebug latest              |
| MySQL 5.7    | 3306         | Data persists in `./mysql/5.7.44/` |
| MySQL 8.4    | 3308         | Data persists in `./mysql/8.4.9/`  |
| PostgreSQL   | 5432         | Data persists in `./postgres/`     |
| phpMyAdmin   | 8080         | MySQL 5.7                          |
| phpMyAdmin 8 | 8088         | MySQL 8.4                          |
| pgAdmin      | 5050         |                                    |

All services share the `devstack_network` bridge network.

### Project Organization

There are two kinds of projects:

**Internal projects** — created inside `www/phpXX/` on the container volume. Accessible at `http://localhost:PORT/project-name/`. Persist across restarts automatically.

**Mounted projects** — external directories bind-mounted into containers. Tracked in `.devstack_projects` (format: `php-version:project-name:source-path:type`, where `type` is `laravel` or empty). They are auto-remounted on `start`/`restart`. Accessible at `http://localhost:PORT/project-name/`.

**Laravel projects**: when mounted with the `laravel` type, devstack generates an Apache `Alias` directive (`/etc/apache2/conf-enabled/<name>-laravel.conf` inside the container) that maps `/<name>/` → `/<name>/public/`. This lets Laravel's `public/.htaccess` handle routing normally. Apache is reloaded automatically after writing the conf. Non-Laravel projects are unaffected.

### PHP Container Configuration

Each PHP container (`www/php74/`, `www/php82/`, `www/php84/`) has:

- Its own `Dockerfile` (extends official `php:X.X-apache`)
- A `php.ini` tuned for development: 512M memory, OpCache with timestamp validation, Xdebug on port 9003
- Extensions: PDO MySQL/PostgreSQL, MySQLi, GD, Zip, Intl, Mbstring, OAuth, Curl, Opcache, Redis, ImageMagick
- Composer 2 pre-installed

### Xdebug

All containers are pre-configured for Xdebug 3.x:

- Mode: `debug,coverage`
- Client port: `9003`
- Client host: `host.docker.internal` (works with VS Code on Mac)

### Data Persistence

- MySQL 5.7 data: `./mysql/5.7.44/` (bind-mounted into container)
- MySQL 8.4 data: `./mysql/8.4.9/` (bind-mounted into container)
- PostgreSQL data: `./postgres/16/` (bind-mounted into container)
- Rebuilding images (`build`) does not destroy database data; `clean` does.

## Initial Setup

```bash
cp .env.example .env
# Edit .env if needed (ports, credentials)
./devstack.sh build
```

Default credentials are in `.env.example`: MySQL uses `devstack`/`root`, PostgreSQL uses `postgres`/`postgres`.

## Key Files

- `docker-compose.yml` — service definitions, volumes, network
- `devstack.sh` — all management commands (~700 lines)
- `.devstack_projects` — auto-managed list of mounted external projects
- `www/phpXX/Dockerfile` — per-version image builds
- `www/phpXX/php.ini` — per-version PHP configuration
