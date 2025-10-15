# DevStack - Development Environment

A complete development stack with PHP 7.4, PHP 8.2, MySQL 5.7 and phpMyAdmin using Docker Compose.

## 🚀 Features

- **PHP 7.4** with Apache, Xdebug 3.1.6, Redis, ImageMagick
- **PHP 8.2** with Apache, Xdebug 3.3.2, Redis, ImageMagick
- **MySQL 5.7.44** with data persistence
- **phpMyAdmin** for database administration
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
   ./devstack.sh start
   ```

3. **Access the services:**

   - PHP 7.4: http://localhost:8074
   - PHP 8.2: http://localhost:8082
   - phpMyAdmin: http://localhost:8080

4. **Configure global alias (optional but recommended):**

   ```bash
   # For zsh (macOS) - Replace <DEVSTACK_PATH> with your real path
   echo 'alias devstack="<DEVSTACK_PATH>/devstack.sh"' >> ~/.zshrc
   source ~/.zshrc

   # Example: echo 'alias devstack="$HOME/devstack/devstack.sh"' >> ~/.zshrc

   # Then use from any directory:
   devstack start
   devstack info
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
./devstack.sh php74       # Access PHP 7.4 container
./devstack.sh php82       # Access PHP 8.2 container
./devstack.sh mysql       # Access MySQL shell
./devstack.sh info        # Show service information
```

### Configure Global Alias (Recommended)

To use `devstack` from any directory without needing `./` and without being in the project directory:

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

## 🔧 Configuration

### Environment variables (`.env`)

| Variable                 | Description         | Default value |
| ------------------------ | ------------------- | ------------- |
| `MYSQL_57_PORT`          | MySQL 5.7 port      | `3306`        |
| `PHP_74_PORT`            | PHP 7.4 port        | `8074`        |
| `PHP_82_PORT`            | PHP 8.2 port        | `8082`        |
| `PHPMYADMIN_PORT`        | phpMyAdmin port     | `8080`        |
| `MYSQL_57_ROOT_PASSWORD` | MySQL root password | `root`        |
| `MYSQL_57_DATABASE`      | Default database    | `devstack`    |
| `MYSQL_57_USER`          | MySQL user          | `devstack`    |
| `MYSQL_57_PASSWORD`      | User password       | `root`        |

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

### File permissions

```bash
# Adjust permissions if necessary
sudo chown -R $USER:$USER ./mysql/
```

### Clean everything and start fresh

```bash
./devstack.sh clean
./devstack.sh build
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
        'php74:Access PHP 7.4 container'
        'php82:Access PHP 8.2 container'
        'mysql:Access MySQL shell'
        'info:Show service information'
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

### Autocompletado para el alias (opcional)

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
        'php74:Access PHP 7.4 container'
        'php82:Access PHP 8.2 container'
        'mysql:Access MySQL shell'
        'info:Show service information'
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

## License

This project is under the MIT License. See the LICENSE file for more details.

## 🤝 Contributions

Contributions are welcome. Please:

1. Fork the project
2. Create a branch for your feature (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request
