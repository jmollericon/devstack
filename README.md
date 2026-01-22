# DevStack - Development Environment

A complete development stack with PHP 7.4, PHP 8.2, PHP 8.5, MySQL 5.7, PostgreSQL 16 and administration tools using Docker Compose.

## 🚀 Features

- **PHP 7.4** with Apache, Xdebug 3.1.6, Redis, ImageMagick
- **PHP 8.2** with Apache, Xdebug 3.3.2, Redis, ImageMagick
- **PHP 8.5** with Apache, Xdebug 3.4.0, Redis, ImageMagick
- **MySQL 5.7.44** with data persistence
- **PostgreSQL 16** with data persistence
- **phpMyAdmin** for MySQL database administration
- **pgAdmin 4** for PostgreSQL database administration
- **Optimized configuration** for development
- **Environment variables** for easy customization
- **Management script** for common commands

## 📋 Requirements

- Docker Desktop
- Docker Compose v2+

## ⚡ Quick Start

1. **Clone and configure:**

   ```bash
   cd devstack
   cp .env.example .env
   # Edit .env with your configurations
   ```

   > **💡 Get the full path:** Run `pwd` inside the devstack directory to get the full path you'll need to configure the alias.

2. **Start the stack:**

   ```bash
   # Initial setup (from devstack directory)
   ./devstack.sh start
   ```

3. **Access the services:**
   - PHP 7.4: http://localhost:8074
   - PHP 8.2: http://localhost:8082
   - PHP 8.5: http://localhost:8085
   - phpMyAdmin: http://localhost:8080
   - pgAdmin: http://localhost:5050

4. **Configure global alias (optional but recommended):**

   ```bash
   # For zsh (macOS) - Replace <DEVSTACK_PATH> with your real path
   echo 'alias devstack="<DEVSTACK_PATH>/devstack.sh"' >> ~/.zshrc
   source ~/.zshrc

   # Example: echo 'alias devstack="$HOME/devstack/devstack.sh"' >> ~/.zshrc

   # Then use from any directory:
   devstack start
   devstack info
   devstack mount ~/my-project php82
   ```

## 🛠️ Available Commands

### Management script (`./devstack.sh`)

```bash
./devstack.sh start       # Start all services
./devstack.sh stop        # Stop all services
./devstack.sh restart     # Restart all services
./devstack.sh build       # Rebuild and start services
./devstack.sh logs        # View logs from all services
./devstack.sh status      # Show status of services
./devstack.sh clean       # Clean everything (DESTRUCTIVE)
./devstack.sh clearcache  # Clear PHP opcache for development
./devstack.sh php74       # Access PHP 7.4 container
./devstack.sh php82       # Access PHP 8.2 container
./devstack.sh php85       # Access PHP 8.5 container
./devstack.sh mysql       # Access MySQL shell
./devstack.sh postgres    # Access PostgreSQL shell
./devstack.sh info        # Show service information
./devstack.sh mount       # Mount external project
./devstack.sh unmount     # Unmount project
./devstack.sh mounts      # List mounted projects
```

### With Global Alias (Recommended)

```bash
devstack start           # Start all services
devstack stop            # Stop all services
devstack restart         # Restart all services
devstack build           # Rebuild and start services
devstack logs            # View logs from all services
devstack status          # Show status of services
devstack clean           # Clean everything (DESTRUCTIVE)
devstack clearcache      # Clear PHP opcache for development
devstack php74           # Access PHP 7.4 container
devstack php82           # Access PHP 8.2 container
devstack php85           # Access PHP 8.5 container
devstack mysql           # Access MySQL shell
devstack postgres        # Access PostgreSQL shell
devstack info            # Show service information
devstack mount           # Mount external project
devstack unmount         # Unmount project
devstack mounts          # List mounted projects
```

### Configure Global Alias (Recommended)

To use `devstack` from any directory without needing `./` and without being in the project directory:

> **✅ Enhanced:** The script now automatically detects its own location, so it works correctly from any directory once the alias is configured.

#### 🔍 First step: Get the full path

```bash
# Navigate to DevStack directory and get the full path
cd devstack
pwd
# Example output: /Users/your-user/Projects/devstack
# Copy this path to use in the following steps
```

#### For zsh (macOS default):

```bash
# Add to the end of ~/.zshrc - Change <DEVSTACK_PATH> to your real path
echo 'alias devstack="<DEVSTACK_PATH>/devstack.sh"' >> ~/.zshrc
source ~/.zshrc

# Common path examples:
# echo 'alias devstack="$HOME/devstack/devstack.sh"' >> ~/.zshrc
# echo 'alias devstack="$HOME/Projects/devstack/devstack.sh"' >> ~/.zshrc
```

#### For bash:

```bash
# Add to the end of ~/.bashrc or ~/.bash_profile
echo 'alias devstack="<DEVSTACK_PATH>/devstack.sh"' >> ~/.bashrc
source ~/.bashrc

# Example: echo 'alias devstack="$HOME/devstack/devstack.sh"' >> ~/.bashrc
```

#### Usage after configuring the alias:

```bash
devstack start           # From any directory
devstack stop            # No need for ./
devstack php74           # Direct access
devstack info            # Quick information
```

### Traditional Docker Compose

```bash
docker-compose up -d      # Start services
docker-compose down       # Stop services
docker-compose logs -f    # View logs in real time
docker-compose ps         # View container status
```

## Project Management

### Mounting External Projects

You can easily mount external projects using Docker bind mounts in your DevStack environment:

```bash
# Mount current directory as "project" in PHP 8.5
devstack mount . php85

# Mount specific project with custom name
devstack mount ~/Projects/my-app php74 myapp

# Mount Laravel project
devstack mount ~/Code/laravel-blog php82 blog

# List all mounted projects
devstack mounts

# List mounts for specific PHP version
devstack mounts php74

# Remove a mounted project
devstack unmount php82 project
devstack unmount php74 myapp
```

### How It Works

- **Complete Docker Compose management**: All containers are managed by docker-compose for consistency
- **Automatic project persistence**: Projects are automatically remounted after `stop`+`start` or `restart`
- **Docker bind mounts**: No file duplication - real-time synchronization between host and container
- **Unified information display**: All services and mounted projects shown in a single view
- **Smart container restart**: Only affected containers are restarted when mounting/unmounting projects

**Project access:**

- PHP 7.4: `http://localhost:8074/project-name/`
- PHP 8.2: `http://localhost:8082/project-name/`
- PHP 8.5: `http://localhost:8085/project-name/`
- If no name is provided, "project" is used as default

**Persistence across sessions:**

- Projects remain mounted after `devstack stop` + `devstack start`
- Projects are automatically restored after `devstack restart`
- Configuration stored in `.devstack_projects` (automatically managed)

### Examples

```bash
# Mount a WordPress site
devstack mount ~/Sites/wordpress-site php74 wp

# Access it at: http://localhost:8074/wp/

# Mount a Laravel API
devstack mount ~/Code/api-project php82 api

# Access it at: http://localhost:8082/api/

# Remove when done
devstack unmount php82 api
```

### Unified Information Display

DevStack now provides a comprehensive status overview showing both services and mounted projects:

```bash
# When you run: devstack info
=== DevStack Information ===
PHP 7.4 Web:     http://localhost:8074
PHP 8.2 Web:     http://localhost:8082
PHP 8.5 Web:     http://localhost:8085
phpMyAdmin:      http://localhost:8080
pgAdmin:         http://localhost:5050
MySQL Host:      localhost:3306
PostgreSQL Host: localhost:5432
MySQL User:      devstack
MySQL Database:  devstack

=== Mounted Projects ===
PHP 7.4 Projects:
  wp → http://localhost:8074/wp/
    📁 Source: /Users/user/Sites/wordpress-site
  laravel-app → http://localhost:8074/laravel-app/
    📁 Source: /Users/user/Code/laravel-project

PHP 8.2 Projects:
  api → http://localhost:8082/api/
    📁 Source: /Users/user/Code/api-project
  shop → http://localhost:8082/shop/
    📁 Source: /Users/user/Code/ecommerce
```

### Enhanced Project Listing

```bash
# List all mounted projects: devstack mounts
DevStack Mounted Projects:

php74:
  wp → http://localhost:8074/wp/
    📁 Source: /Users/user/Sites/wordpress-site
  laravel-app → http://localhost:8074/laravel-app/
    📁 Source: /Users/user/Code/laravel-project

php82:
  api → http://localhost:8082/api/
    📁 Source: /Users/user/Code/api-project
```

## � Development Optimizations

### Real-time Change Detection

DevStack is optimized for development with instant change detection:

**OpCache Configuration:**

- `opcache.revalidate_freq = 0` - Files are checked immediately for changes
- `opcache.validate_timestamps = 1` - Timestamp validation enabled
- Applied to both PHP 7.4 and PHP 8.2 containers

**Clear Cache When Needed:**

```bash
# Clear PHP opcache for all containers
devstack clearcache

# This will:
# ✅ Clear PHP 7.4 opcache
# ✅ Clear PHP 8.2 opcache
# ✅ Provide browser cache tips
```

### Troubleshooting Slow Changes

If changes aren't reflecting immediately:

1. **Use the cache clear command:**

   ```bash
   devstack clearcache
   ```

2. **Force browser refresh:**
   - **Windows/Linux**: `Ctrl + F5`
   - **Mac**: `Cmd + Shift + R`
   - **Or enable "Disable cache" in browser dev tools (F12)**

3. **For Laravel projects**, also clear application cache:
   ```bash
   devstack php74  # or php82
   php artisan cache:clear
   php artisan config:clear
   php artisan view:clear
   ```

### Performance Tips

- **Development mode**: OpCache is optimized for immediate change detection
- **Real-time editing**: All mounted projects support live editing
- **No file duplication**: Changes in your IDE reflect instantly in containers

## �🔧 Configuration

### Environment variables (`.env`)

| Variable                   | Description            | Default value          |
| -------------------------- | ---------------------- | ---------------------- |
| `MYSQL_57_PORT`            | MySQL 5.7 port         | `3306`                 |
| `POSTGRES_PORT`            | PostgreSQL 16 port     | `5432`                 |
| `PHP_74_PORT`              | PHP 7.4 port           | `8074`                 |
| `PHP_82_PORT`              | PHP 8.2 port           | `8082`                 |
| `PHP_85_PORT`              | PHP 8.5 port           | `8085`                 |
| `PHPMYADMIN_PORT`          | phpMyAdmin port        | `8080`                 |
| `PGADMIN_PORT`             | pgAdmin port           | `5050`                 |
| `MYSQL_57_ROOT_PASSWORD`   | MySQL root password    | `root`                 |
| `MYSQL_57_DATABASE`        | MySQL default database | `devstack`             |
| `MYSQL_57_USER`            | MySQL user             | `devstack`             |
| `MYSQL_57_PASSWORD`        | MySQL user password    | `root`                 |
| `POSTGRES_PASSWORD`        | PostgreSQL password    | `postgres`             |
| `POSTGRES_USER`            | PostgreSQL user        | `postgres`             |
| `POSTGRES_DB`              | PostgreSQL database    | `devstack`             |
| `PGADMIN_DEFAULT_EMAIL`    | pgAdmin login email    | `admin@devstack.local` |
| `PGADMIN_DEFAULT_PASSWORD` | pgAdmin login password | `admin`                |

### Advanced Alias Configuration

For an even smoother experience, you can create a function that automatically changes to the project directory:

#### Advanced function for zsh:

```bash
# Add to the end of ~/.zshrc - Change <DEVSTACK_PATH> to your real path
function devstack() {
    local DEVSTACK_DIR="<DEVSTACK_PATH>"
    local CURRENT_DIR=$(pwd)

    cd "$DEVSTACK_DIR"
    ./devstack.sh "$@"
    local EXIT_CODE=$?

    # Return to original directory
    cd "$CURRENT_DIR"
    return $EXIT_CODE
}

# Example: local DEVSTACK_DIR="$HOME/devstack"
```

#### Advanced function for bash:

```bash
# Add to the end of ~/.bashrc - Change <DEVSTACK_PATH> to your real path
devstack() {
    local DEVSTACK_DIR="<DEVSTACK_PATH>"
    local CURRENT_DIR=$(pwd)

    cd "$DEVSTACK_DIR"
    ./devstack.sh "$@"
    local EXIT_CODE=$?

    # Return to original directory
    cd "$CURRENT_DIR"
    return $EXIT_CODE
}

# Example: local DEVSTACK_DIR="$HOME/devstack"
```

#### Simple alias (recommended for most users):

```bash
# For zsh (add to ~/.zshrc)
alias devstack="cd <DEVSTACK_PATH> && ./devstack.sh"

# For bash (add to ~/.bashrc)
alias devstack="cd <DEVSTACK_PATH> && ./devstack.sh"

# Examples:
# alias devstack="cd $HOME/devstack && ./devstack.sh"
# alias devstack="cd $HOME/Projects/devstack && ./devstack.sh"
```

> **Note:** Replace `<DEVSTACK_PATH>` with the real path where you have DevStack installed on your system. You can use variables like `$HOME` to make the configuration more portable.

## 🐛 Debugging with Xdebug

### Configuration for VS Code

1. **Install PHP Debug extension**

2. **Configure `.vscode/launch.json`:**

   ```json
   {
     "version": "0.2.0",
     "configurations": [
       {
         "name": "Listen for Xdebug (PHP 7.4)",
         "type": "php",
         "request": "launch",
         "port": 9003,
         "pathMappings": {
           "/var/www/html": "${workspaceFolder}"
         }
       },
       {
         "name": "Listen for Xdebug (PHP 8.2)",
         "type": "php",
         "request": "launch",
         "port": 9003,
         "pathMappings": {
           "/var/www/html": "${workspaceFolder}"
         }
       }
     ]
   }
   ```

3. **Start debugging in VS Code and set breakpoints**

## 📦 Project Structure

```
devstack/
├── docker-compose.yml      # Main configuration
├── .env                    # Environment variables
├── .env.example           # Variable template
├── devstack.sh            # Management script
├── www/
│   ├── php74/
│   │   ├── Dockerfile     # PHP 7.4 image
│   │   ├── php.ini        # PHP 7.4 configuration
│   │   └── .dockerignore
│   └── php82/
│       ├── Dockerfile     # PHP 8.2 image
│       ├── php.ini        # PHP 8.2 configuration
│       └── .dockerignore
└── mysql/
    └── 5.7.44/           # MySQL persistent data
```

## 🔍 Container Information

### PHP 7.4 (`apache-php7.4`)

- **Base:** php:7.4-apache
- **Extensions:** PDO, MySQLi, GD, Zip, Intl, Mbstring, Xdebug 3.1.6, Redis 5.3.7, ImageMagick
- **Port:** 8074
- **Document root:** `/var/www/html`

### PHP 8.2 (`apache-php8.2`)

- **Base:** php:8.2-apache
- **Extensions:** PDO, MySQLi, GD, Zip, Intl, Mbstring, Xdebug 3.3.2, Redis 6.0.2, ImageMagick
- **Port:** 8082
- **Document root:** `/var/www/html`

### MySQL 5.7.44 (`mysql5.7.44`)

- **User:** devstack / root
- **Password:** root / root
- **Database:** devstack
- **Port:** 3306

### phpMyAdmin (`phpmyadmin`)

- **Access:** http://localhost:8080
- **User:** devstack or root
- **Password:** root

## 🚨 Troubleshooting

### Occupied ports error

```bash
# Change ports in .env
PHP_74_PORT=9074
PHP_82_PORT=9082
PHPMYADMIN_PORT=9080
MYSQL_57_PORT=3307
```

### Script works from any directory

The script automatically detects its location and loads the correct `.env` file. If you encounter issues:

```bash
# Make sure the alias points to the full path
which devstack
# Should show: /path/to/your/devstack/devstack.sh

# Test from any directory
cd /tmp
devstack status
```

### File permissions

```bash
# Adjust permissions if necessary
sudo chown -R $USER:$USER ./mysql/
```

### Clean everything and start fresh

```bash
devstack clean
devstack build
```

### View specific logs

```bash
docker-compose logs database    # MySQL only
docker-compose logs php74       # PHP 7.4 only
docker-compose logs php82       # PHP 8.2 only
```

## 💡 Tips and Tricks

### Useful commands with configured alias

```bash
# Check status quickly
devstack status

# View service information
devstack info

# Quick access to containers
devstack php82    # Enter PHP 8.2
devstack mysql    # Direct MySQL access

# Real-time logs
devstack logs
```

### Autocompletion for the alias (optional)

To enable autocompletion in zsh:

```bash
# Add to ~/.zshrc
_devstack_completion() {
    local -a commands
    commands=(
        'start:Start all services'
        'stop:Stop all services'
        'restart:Restart all services'
        'build:Rebuild and start services'
        'logs:View logs from all services'
        'status:Show status of services'
        'clean:Clean everything (DESTRUCTIVE)'
        'clearcache:Clear PHP opcache for development'
        'php74:Access PHP 7.4 container'
        'php82:Access PHP 8.2 container'
        'mysql:Access MySQL shell'
        'info:Show service information'
        'mount:Mount external project'
        'unmount:Unmount project'
        'mounts:List mounted projects'
        'help:Show help'
    )
    _describe 'commands' commands
}

compdef _devstack_completion devstack
```

### Useful environment variables

```bash
# Export for use in other scripts - Change <DEVSTACK_PATH> to your real path
export DEVSTACK_DIR="<DEVSTACK_PATH>"
export DEVSTACK_PHP74_PORT="8074"
export DEVSTACK_PHP82_PORT="8082"

# Examples:
# export DEVSTACK_DIR="$HOME/devstack"
# export DEVSTACK_DIR="$HOME/Projects/devstack"
```

## 💡 Tips and Tricks

### Useful commands with configured alias

```bash
# Check status quickly
devstack status

# View service information
devstack info

# Quick access to containers
devstack php82    # Enter PHP 8.2
devstack mysql    # Direct MySQL access

# Real-time logs
devstack logs
```

### Shell Autocompletion (optional)

To enable autocompletion in zsh:

```bash
# Add to ~/.zshrc
_devstack_completion() {
    local -a commands
    commands=(
        'start:Start all services'
        'stop:Stop all services'
        'restart:Restart all services'
        'build:Rebuild and start services'
        'logs:View logs from all services'
        'status:Show status of services'
        'clean:Clean everything (DESTRUCTIVE)'
        'clearcache:Clear PHP opcache for development'
        'php74:Access PHP 7.4 container'
        'php82:Access PHP 8.2 container'
        'mysql:Access MySQL shell'
        'info:Show service information'
        'mount:Mount external project'
        'unmount:Unmount project'
        'mounts:List mounted projects'
        'help:Show help'
    )
    _describe 'commands' commands
}

compdef _devstack_completion devstack
```

### Useful environment variables

```bash
# Export for use in other scripts - Change <DEVSTACK_PATH> to your real path
export DEVSTACK_DIR="<DEVSTACK_PATH>"
export DEVSTACK_PHP74_PORT="8074"
export DEVSTACK_PHP82_PORT="8082"

# Examples:
# export DEVSTACK_DIR="$HOME/devstack"
# export DEVSTACK_DIR="$HOME/Projects/devstack"
```

## 🆕 Recent Improvements

### v2.0 - Enhanced Development Experience

**🚀 Performance Optimizations:**

- **Instant change detection**: OpCache optimized with `revalidate_freq = 0`
- **Real-time file monitoring**: Changes reflect immediately in browser
- **New `clearcache` command**: Clear PHP opcache when needed

**📁 Enhanced Project Management:**

- **Improved project listing**: Shows both URL and source path
- **Optimized restart logic**: Bulk container restarts instead of individual
- **Better information display**: Cleaner, more readable project information
- **Smart path formatting**: Compact display with full source paths

**🔧 Developer Experience:**

- **Updated documentation**: Comprehensive troubleshooting guides
- **Enhanced autocompletion**: Includes all new commands
- **Better error messages**: Clear guidance for common issues
- **Performance tips**: Best practices for development workflow

**🔄 System Improvements:**

- **Consistent container management**: All operations use docker-compose
- **Automatic project persistence**: Projects survive stop/start cycles
- **Bulk operations**: Multiple containers handled efficiently
- **Enhanced logging**: Better feedback during operations

### Migration Notes

**Existing projects**: No migration needed - all projects remain functional
**Configuration**: OpCache automatically optimized for development
**New features**: Use `devstack clearcache` if experiencing cache issues

## License

This project is under the MIT License. See the LICENSE file for more details.

## 🤝 Contributions

Contributions are welcome. Please:

1. Fork the project
2. Create a branch for your feature (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request
