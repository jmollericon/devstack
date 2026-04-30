# DevStack - Development Environment

A complete development stack with PHP 7.4, PHP 8.2, PHP 8.4, MySQL 5.7, PostgreSQL 16 and administration tools using Docker Compose.

## Features

- **PHP 7.4** with Apache, Xdebug 3.1.6, Redis, ImageMagick
- **PHP 8.2** with Apache, Xdebug 3.3.2, Redis, ImageMagick
- **PHP 8.4** with Apache, Xdebug, Redis, ImageMagick
- **MySQL 5.7.44** with data persistence
- **PostgreSQL 16** with data persistence
- **phpMyAdmin** for MySQL administration
- **pgAdmin 4** for PostgreSQL administration
- **Laravel support** — subdirectory Alias mode and dedicated-port VirtualHost mode
- **OpCache** tuned for instant change detection in development
- **Xdebug 3** pre-configured for VS Code on port 9003

## Requirements

- Docker Desktop
- Docker Compose v2+

## Quick Start

```bash
cd devstack
cp .env.example .env
./devstack.sh start
```

Services:
- PHP 7.4: http://localhost:8074
- PHP 8.2: http://localhost:8082
- PHP 8.4: http://localhost:8084
- phpMyAdmin: http://localhost:8080
- pgAdmin: http://localhost:5050

**Global alias (recommended):**

```bash
echo 'alias devstack="<DEVSTACK_PATH>/devstack.sh"' >> ~/.zshrc
source ~/.zshrc
```

## Commands

```bash
devstack start                           # Start all services
devstack stop                            # Stop all services
devstack restart                         # Restart all services
devstack build                           # Rebuild images and start
devstack logs                            # Stream logs
devstack status                          # Show container status
devstack info                            # Show all URLs and mounted projects
devstack clearcache                      # Clear PHP OpCache
devstack clean                           # Remove all containers and volumes (DESTRUCTIVE)

devstack php74                           # Shell into PHP 7.4 container
devstack php82                           # Shell into PHP 8.2 container
devstack php84                           # Shell into PHP 8.4 container
devstack mysql                           # MySQL CLI
devstack postgres                        # PostgreSQL CLI

devstack mount <path> <php> [name]               # Mount a project
devstack mount <path> <php> <name> laravel       # Mount Laravel (subdirectory mode)
devstack mount <path> <php> <name> laravel <port> # Mount Laravel (dedicated port mode)
devstack unmount <php> [name]                    # Unmount a project
devstack mounts [php]                            # List mounted projects
```

## Project Mounting

Projects are bind-mounted into the containers and tracked in `.devstack_projects`. They survive `stop`/`start` and `restart` automatically.

### Regular projects (PHP, CodeIgniter, WordPress, etc.)

```bash
devstack mount ~/Sites/wordpress php74 wp
# → http://localhost:8074/wp/

devstack mount ~/Projects/codeigniter-app php74 erp
# → http://localhost:8074/erp/
```

### Laravel projects — two modes

Laravel projects need special handling because Apache must serve from `public/`, not the project root. DevStack supports two modes depending on the app architecture.

#### Mode 1: Subdirectory (simple Laravel apps)

For Laravel apps that don't use root-relative JavaScript API calls — i.e., the frontend uses `url()` or `route()` helper for all paths.

```bash
devstack mount ~/Projects/my-laravel php82 myapp laravel
# → http://localhost:8082/myapp/
```

In the project's `.env`:
```
APP_URL=http://localhost:8082/myapp
```

Apache generates an `Alias` that maps `/myapp/` → `public/` and handles mod_rewrite internally (no `.htaccess` dependency).

#### Mode 2: Dedicated port (SPA / Inertia.js / API apps)

For full-stack apps that use root-relative paths in JavaScript (e.g., `/api/client/total`, Inertia.js, Ziggy). These apps must run at the root of a domain — a subdirectory breaks URL generation and API routing.

```bash
devstack mount ~/Projects/laravel-spa php74 myapp laravel 8076
# → http://localhost:8076/
```

In the project's `.env`:
```
APP_URL=http://localhost:8076
DB_HOST=mysql57
DB_PORT=3306
```

Apache generates a full `VirtualHost` on port 8076 with `DocumentRoot` pointing to `public/`. The app behaves as if it owns the entire domain. Use ports 8075–8099 (or any free port) for additional projects.

**When to use each mode:**

| App type | Mode |
|---|---|
| Traditional server-rendered Laravel | Subdirectory |
| Laravel with Vue/React + Inertia.js | Dedicated port |
| Laravel API (Axios/fetch with `/api/...` paths) | Dedicated port |
| Laravel with Ziggy route generation | Dedicated port |

### MySQL from inside the container

When connecting to devstack's MySQL from a Laravel project's `.env`, use the service name, not `localhost`:

```
DB_HOST=mysql57
DB_PORT=3306
```

### `devstack info` output with Laravel projects

```
=== Mounted Projects ===
PHP 7.4 Projects:
  pgr-invoice [Laravel:port] → http://localhost:8076/
    📁 Source: /Users/jorge/Work/projects/pgr-invoice
  erp-base-ci → http://localhost:8074/erp-base-ci/
    📁 Source: /Users/jorge/Work/projects/erp-base-ci

PHP 8.2 Projects:
  filament [Laravel] → http://localhost:8082/filament/
    📁 Source: /var/www/html/filament (internal)
```

## Configuration

### Environment variables (`.env`)

| Variable | Description | Default |
|---|---|---|
| `PHP_74_PORT` | PHP 7.4 port | `8074` |
| `PHP_82_PORT` | PHP 8.2 port | `8082` |
| `PHP_84_PORT` | PHP 8.4 port | `8084` |
| `MYSQL_57_PORT` | MySQL port | `3306` |
| `POSTGRES_PORT` | PostgreSQL port | `5432` |
| `PHPMYADMIN_PORT` | phpMyAdmin port | `8080` |
| `PGADMIN_PORT` | pgAdmin port | `5050` |
| `MYSQL_57_ROOT_PASSWORD` | MySQL root password | `root` |
| `MYSQL_57_DATABASE` | MySQL default database | `devstack` |
| `MYSQL_57_USER` | MySQL user | `devstack` |
| `MYSQL_57_PASSWORD` | MySQL user password | `root` |
| `POSTGRES_PASSWORD` | PostgreSQL password | `postgres` |
| `POSTGRES_USER` | PostgreSQL user | `postgres` |
| `POSTGRES_DB` | PostgreSQL database | `devstack` |
| `PGADMIN_DEFAULT_EMAIL` | pgAdmin login | `admin@admin.com` |
| `PGADMIN_DEFAULT_PASSWORD` | pgAdmin password | `admin` |

### Rebuilding after config changes

Rebuild is needed when you change `Dockerfile`, `php.ini`, or `docker-compose.yml`. For `.env`-only changes, `restart` is sufficient.

```bash
./devstack.sh build          # Rebuild all (data is preserved)
docker-compose build --no-cache php74  # Rebuild single service
```

## Debugging with Xdebug

All containers are pre-configured with Xdebug 3 on port 9003, mode `debug,coverage`.

**VS Code `launch.json`:**

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Listen for Xdebug",
      "type": "php",
      "request": "launch",
      "port": 9003,
      "pathMappings": {
        "/var/www/html/your-project": "${workspaceFolder}"
      }
    }
  ]
}
```

The trigger is `XDEBUG_SESSION=VSCODE` in the query string or via a browser extension.

## Troubleshooting

**Port already in use:** Change the relevant port in `.env` and restart.

**Laravel app double-prefix URLs or broken API calls:** The app needs dedicated port mode (see [Mode 2](#mode-2-dedicated-port-spa--inertiajs--api-apps) above). Common sign: frontend calls `/api/...` without a subdirectory prefix.

**MySQL connection from Laravel container fails:**
```
DB_HOST=mysql57   # service name, not localhost or 127.0.0.1
DB_PORT=3306      # internal port, not the host-mapped port
```

**OpCache serving stale files:**
```bash
devstack clearcache
# Then hard-refresh browser: Cmd+Shift+R / Ctrl+F5
```

**Clean slate:**
```bash
devstack clean   # removes containers and volumes (databases deleted)
devstack build
```

**View logs for a specific service:**
```bash
docker-compose logs -f php74
docker-compose logs -f mysql57
```

## Internal Project Structure

```
devstack/
├── docker-compose.yml       # Service definitions
├── .env                     # Active configuration
├── .env.example             # Template
├── devstack.sh              # Management CLI
├── .devstack_projects       # Auto-managed mount registry
├── www/
│   ├── php74/               # PHP 7.4 build context (Dockerfile, php.ini)
│   ├── php82/               # PHP 8.2 build context
│   └── php84/               # PHP 8.4 build context
├── mysql/5.7.44/            # MySQL persistent data
└── postgres/16/             # PostgreSQL persistent data
```

`.devstack_projects` format: `php-version:name:source-path:type:port`
- `type`: `laravel` or empty
- `port`: dedicated port number (laravel mode 2) or empty (mode 1 or non-Laravel)
