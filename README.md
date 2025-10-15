# DevStack - Development Environment

Un stack de desarrollo completo con PHP 7.4, PHP 8.2, MySQL 5.7 y phpMyAdmin usando Docker Compose.

## 🚀 Características

- **PHP 7.4** con Apache, Xdebug 3.1.6, Redis, ImageMagick
- **PHP 8.2** con Apache, Xdebug 3.3.2, Redis, ImageMagick
- **MySQL 5.7.44** con persistencia de datos
- **phpMyAdmin** para administración de base de datos
- **Configuración optimizada** para desarrollo
- **Variables de entorno** para fácil personalización
- **Script de gestión** para comandos comunes

## 📋 Requisitos

- Docker Desktop
- Docker Compose v2+

## ⚡ Inicio Rápido

1. **Clonar y configurar:**

   ```bash
   cd devstack
   cp .env.example .env
   # Editar .env con tus configuraciones
   ```

   > **💡 Obtener la ruta completa:** Ejecuta `pwd` dentro del directorio devstack para obtener la ruta completa que necesitarás para configurar el alias.

2. **Iniciar el stack:**

   ```bash
   ./devstack.sh start
   ```

3. **Acceder a los servicios:**

   - PHP 7.4: http://localhost:8074
   - PHP 8.2: http://localhost:8082
   - phpMyAdmin: http://localhost:8080

4. **Configurar alias global (opcional pero recomendado):**

   ```bash
   # Para zsh (macOS) - Reemplaza <RUTA_AL_DEVSTACK> con tu ruta real
   echo 'alias devstack="<RUTA_AL_DEVSTACK>/devstack.sh"' >> ~/.zshrc
   source ~/.zshrc

   # Ejemplo: echo 'alias devstack="$HOME/devstack/devstack.sh"' >> ~/.zshrc

   # Luego usar desde cualquier directorio:
   devstack start
   devstack info
   ```

## 🛠️ Comandos Disponibles

### Script de gestión (`./devstack.sh`)

```bash
./devstack.sh start       # Iniciar todos los servicios
./devstack.sh stop        # Detener todos los servicios
./devstack.sh restart     # Reiniciar todos los servicios
./devstack.sh build       # Reconstruir e iniciar servicios
./devstack.sh logs        # Ver logs de todos los servicios
./devstack.sh status      # Ver estado de los servicios
./devstack.sh clean       # Limpiar todo (DESTRUCTIVO)
./devstack.sh php74       # Acceder al contenedor PHP 7.4
./devstack.sh php82       # Acceder al contenedor PHP 8.2
./devstack.sh mysql       # Acceder a MySQL shell
./devstack.sh info        # Mostrar información de servicios
```

### Configurar Alias Global (Recomendado)

Para usar `devstack` desde cualquier directorio sin necesidad de `./` y sin estar en el directorio del proyecto:

#### 🔍 Primer paso: Obtener la ruta completa

```bash
# Navegar al directorio de DevStack y obtener la ruta completa
cd devstack
pwd
# Ejemplo de salida: /Users/tu-usuario/Projects/devstack
# Copia esta ruta para usar en los siguientes pasos
```

#### Para zsh (macOS por defecto):

```bash
# Agregar al final de ~/.zshrc - Cambia <RUTA_AL_DEVSTACK> por tu ruta real
echo 'alias devstack="<RUTA_AL_DEVSTACK>/devstack.sh"' >> ~/.zshrc
source ~/.zshrc

# Ejemplos de rutas comunes:
# echo 'alias devstack="$HOME/devstack/devstack.sh"' >> ~/.zshrc
# echo 'alias devstack="$HOME/Projects/devstack/devstack.sh"' >> ~/.zshrc
```

#### Para bash:

```bash
# Agregar al final de ~/.bashrc o ~/.bash_profile
echo 'alias devstack="<RUTA_AL_DEVSTACK>/devstack.sh"' >> ~/.bashrc
source ~/.bashrc

# Ejemplo: echo 'alias devstack="$HOME/devstack/devstack.sh"' >> ~/.bashrc
```

#### Uso después de configurar el alias:

```bash
devstack start           # Desde cualquier directorio
devstack stop            # Sin necesidad de ./
devstack php74           # Acceso directo
devstack info            # Información rápida
```

### Docker Compose tradicional

```bash
docker-compose up -d      # Iniciar servicios
docker-compose down       # Detener servicios
docker-compose logs -f    # Ver logs en tiempo real
docker-compose ps         # Ver estado de contenedores
```

## 🔧 Configuración

### Variables de entorno (`.env`)

| Variable                 | Descripción               | Valor por defecto |
| ------------------------ | ------------------------- | ----------------- |
| `MYSQL_57_PORT`          | Puerto de MySQL 5.7       | `3306`            |
| `PHP_74_PORT`            | Puerto de PHP 7.4         | `8074`            |
| `PHP_82_PORT`            | Puerto de PHP 8.2         | `8082`            |
| `PHPMYADMIN_PORT`        | Puerto de phpMyAdmin      | `8080`            |
| `MYSQL_57_ROOT_PASSWORD` | Contraseña root de MySQL  | `root`            |
| `MYSQL_57_DATABASE`      | Base de datos por defecto | `devstack`        |
| `MYSQL_57_USER`          | Usuario de MySQL          | `devstack`        |
| `MYSQL_57_PASSWORD`      | Contraseña de usuario     | `root`            |

### Configuración Avanzada del Alias

Para una experiencia aún más fluida, puedes crear una función que cambie automáticamente al directorio del proyecto:

#### Función avanzada para zsh:

```bash
# Agregar al final de ~/.zshrc - Cambia <RUTA_AL_DEVSTACK> por tu ruta real
function devstack() {
    local DEVSTACK_DIR="<RUTA_AL_DEVSTACK>"
    local CURRENT_DIR=$(pwd)

    cd "$DEVSTACK_DIR"
    ./devstack.sh "$@"
    local EXIT_CODE=$?

    # Regresar al directorio original
    cd "$CURRENT_DIR"
    return $EXIT_CODE
}

# Ejemplo: local DEVSTACK_DIR="$HOME/devstack"
```

#### Función avanzada para bash:

```bash
# Agregar al final de ~/.bashrc - Cambia <RUTA_AL_DEVSTACK> por tu ruta real
devstack() {
    local DEVSTACK_DIR="<RUTA_AL_DEVSTACK>"
    local CURRENT_DIR=$(pwd)

    cd "$DEVSTACK_DIR"
    ./devstack.sh "$@"
    local EXIT_CODE=$?

    # Regresar al directorio original
    cd "$CURRENT_DIR"
    return $EXIT_CODE
}

# Ejemplo: local DEVSTACK_DIR="$HOME/devstack"
```

#### Alias simple (recomendado para la mayoría de usuarios):

```bash
# Para zsh (agregar a ~/.zshrc)
alias devstack="cd <RUTA_AL_DEVSTACK> && ./devstack.sh"

# Para bash (agregar a ~/.bashrc)
alias devstack="cd <RUTA_AL_DEVSTACK> && ./devstack.sh"

# Ejemplos:
# alias devstack="cd $HOME/devstack && ./devstack.sh"
# alias devstack="cd $HOME/Projects/devstack && ./devstack.sh"
```

> **Nota:** Reemplaza `<RUTA_AL_DEVSTACK>` con la ruta real donde tienes instalado DevStack en tu sistema. Puedes usar variables como `$HOME` para hacer la configuración más portable.## 🐛 Debugging con Xdebug

### Configuración para VS Code

1. **Instalar extensión PHP Debug**

2. **Configurar `.vscode/launch.json`:**

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

3. **Iniciar debugging en VS Code y establecer breakpoints**

## 📦 Estructura del Proyecto

```
devstack/
├── docker-compose.yml      # Configuración principal
├── .env                    # Variables de entorno
├── .env.example           # Plantilla de variables
├── devstack.sh            # Script de gestión
├── www/
│   ├── php74/
│   │   ├── Dockerfile     # Imagen PHP 7.4
│   │   ├── php.ini        # Configuración PHP 7.4
│   │   └── .dockerignore
│   └── php82/
│       ├── Dockerfile     # Imagen PHP 8.2
│       ├── php.ini        # Configuración PHP 8.2
│       └── .dockerignore
└── mysql/
    └── 5.7.44/           # Datos persistentes de MySQL
```

## 🔍 Información de los Contenedores

### PHP 7.4 (`apache-php7.4`)

- **Base:** php:7.4-apache
- **Extensiones:** PDO, MySQLi, GD, Zip, Intl, Mbstring, Xdebug 3.1.6, Redis 5.3.7, ImageMagick
- **Puerto:** 8074
- **Documentos:** `/var/www/html`

### PHP 8.2 (`apache-php8.2`)

- **Base:** php:8.2-apache
- **Extensiones:** PDO, MySQLi, GD, Zip, Intl, Mbstring, Xdebug 3.3.2, Redis 6.0.2, ImageMagick
- **Puerto:** 8082
- **Documentos:** `/var/www/html`

### MySQL 5.7.44 (`mysql5.7.44`)

- **Usuario:** devstack / root
- **Contraseña:** root / root
- **Base de datos:** devstack
- **Puerto:** 3306

### phpMyAdmin (`phpmyadmin`)

- **Acceso:** http://localhost:8080
- **Usuario:** devstack o root
- **Contraseña:** root

## 🚨 Solución de Problemas

### Error de puertos ocupados

```bash
# Cambiar puertos en .env
PHP_74_PORT=9074
PHP_82_PORT=9082
PHPMYADMIN_PORT=9080
MYSQL_57_PORT=3307
```

### Permisos de archivos

```bash
# Ajustar permisos si es necesario
sudo chown -R $USER:$USER ./mysql/
```

### Limpiar todo y empezar de nuevo

```bash
./devstack.sh clean
./devstack.sh build
```

### Ver logs específicos

```bash
docker-compose logs database    # Solo MySQL
docker-compose logs php74       # Solo PHP 7.4
docker-compose logs php82       # Solo PHP 8.2
```

## � Tips y Trucos

### Comandos útiles con alias configurado

```bash
# Verificar estado rápidamente
devstack status

# Ver información de servicios
devstack info

# Acceso rápido a contenedores
devstack php82    # Entrar a PHP 8.2
devstack mysql    # Acceso directo a MySQL

# Logs en tiempo real
devstack logs
```

### Autocompletado para el alias (opcional)

Para habilitar autocompletado en zsh:

```bash
# Agregar a ~/.zshrc
_devstack_completion() {
    local -a commands
    commands=(
        'start:Iniciar todos los servicios'
        'stop:Detener todos los servicios'
        'restart:Reiniciar todos los servicios'
        'build:Reconstruir e iniciar servicios'
        'logs:Ver logs de todos los servicios'
        'status:Ver estado de los servicios'
        'clean:Limpiar todo (DESTRUCTIVO)'
        'php74:Acceder al contenedor PHP 7.4'
        'php82:Acceder al contenedor PHP 8.2'
        'mysql:Acceder a MySQL shell'
        'info:Mostrar información de servicios'
        'help:Mostrar ayuda'
    )
    _describe 'commands' commands
}

compdef _devstack_completion devstack
```

### Variables de entorno útiles

```bash
# Exportar para uso en otros scripts - Cambia <RUTA_AL_DEVSTACK> por tu ruta real
export DEVSTACK_DIR="<RUTA_AL_DEVSTACK>"
export DEVSTACK_PHP74_PORT="8074"
export DEVSTACK_PHP82_PORT="8082"

# Ejemplos:
# export DEVSTACK_DIR="$HOME/devstack"
# export DEVSTACK_DIR="$HOME/Projects/devstack"
```

## �📄 Licencia

Este proyecto está bajo la Licencia MIT. Consulta el archivo LICENSE para más detalles.

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request
