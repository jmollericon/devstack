#!/bin/bash

# DevStack Management Script
# Simplified script for managing PHP 7.4, PHP 8.2, MySQL 5.7 and phpMyAdmin containers
# Usage: ./devstack.sh [command]

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Load environment variables from script directory
if [ -f "$SCRIPT_DIR/.env" ]; then
    source "$SCRIPT_DIR/.env"
else
    echo -e "${RED}Error: .env file not found in $SCRIPT_DIR. Please copy .env.example to .env and configure it.${NC}"
    exit 1
fi

# Functions
print_help() {
    echo -e "${BLUE}DevStack Management Script${NC}"
    echo ""
    echo "Usage: ./devstack.sh [command]"
    echo ""
    echo "Commands:"
    echo "  start                           Start all services"
    echo "  stop                            Stop all services"
    echo "  restart                         Restart all services"
    echo "  build                           Build/rebuild all services"
    echo "  logs                            Show logs from all services"
    echo "  status                          Show status of all services"
    echo "  clean                           Remove all containers and volumes (DESTRUCTIVE)"
    echo "  mount <path> <php> [name]       Mount project with bind mount"
    echo "  unmount <php> [name]            Unmount project"
    echo "  mounts [php]                    List all mounted projects"
    echo "  php74                           Access PHP 7.4 container shell"
    echo "  php82                           Access PHP 8.2 container shell"
    echo "  mysql                           Access MySQL shell"
    echo "  info                            Show service URLs and information"
    echo "  help                            Show this help message"
    echo ""
    echo "Project Examples:"
    echo "  devstack mount . php74                    # Mount current dir as 'project'"
    echo "  devstack mount ~/Projects/blog php82 blog # Mount with custom name"
    echo "  devstack unmount php74 project           # Unmount project"
    echo "  devstack mounts                           # Show all mounted projects"
}

start_services() {
    echo -e "${GREEN}Starting DevStack services...${NC}"
    cd "$SCRIPT_DIR" && docker-compose up -d
    echo -e "${GREEN}Services started successfully!${NC}"
    show_info
}

stop_services() {
    echo -e "${YELLOW}Stopping DevStack services...${NC}"
    cd "$SCRIPT_DIR" && docker-compose down
    echo -e "${GREEN}Services stopped successfully!${NC}"
}

restart_services() {
    echo -e "${YELLOW}Restarting DevStack services...${NC}"
    cd "$SCRIPT_DIR" && docker-compose down
    cd "$SCRIPT_DIR" && docker-compose up -d
    echo -e "${GREEN}Services restarted successfully!${NC}"
    show_info
}

build_services() {
    echo -e "${BLUE}Building DevStack services...${NC}"
    cd "$SCRIPT_DIR" && docker-compose down
    cd "$SCRIPT_DIR" && docker-compose build --no-cache
    cd "$SCRIPT_DIR" && docker-compose up -d
    echo -e "${GREEN}Services built and started successfully!${NC}"
    show_info
}

show_logs() {
    echo -e "${BLUE}Showing logs from all services...${NC}"
    cd "$SCRIPT_DIR" && docker-compose logs -f
}

show_status() {
    echo -e "${BLUE}DevStack Services Status:${NC}"
    cd "$SCRIPT_DIR" && docker-compose ps
}

clean_everything() {
    echo -e "${RED}WARNING: This will remove all containers, networks, and volumes!${NC}"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Cleaning up everything...${NC}"
        cd "$SCRIPT_DIR" && docker-compose down -v --remove-orphans
        docker system prune -f
        echo -e "${GREEN}Cleanup completed!${NC}"
    else
        echo -e "${BLUE}Cleanup cancelled.${NC}"
    fi
}

access_php74() {
    echo -e "${BLUE}Accessing PHP 7.4 container...${NC}"
    docker exec -it ${PHP74_CONTAINER_NAME} bash
}

access_php82() {
    echo -e "${BLUE}Accessing PHP 8.2 container...${NC}"
    docker exec -it ${PHP82_CONTAINER_NAME} bash
}

access_mysql() {
    echo -e "${BLUE}Accessing MySQL shell...${NC}"
    docker exec -it ${MYSQL57_CONTAINER_NAME} mysql -u${MYSQL_57_USER} -p${MYSQL_57_PASSWORD} ${MYSQL_57_DATABASE}
}

show_info() {
    echo ""
    echo -e "${GREEN}=== DevStack Information ===${NC}"
    echo -e "${BLUE}PHP 7.4 Web:${NC}     http://localhost:${PHP_74_PORT}"
    echo -e "${BLUE}PHP 8.2 Web:${NC}     http://localhost:${PHP_82_PORT}"
    echo -e "${BLUE}phpMyAdmin:${NC}      http://localhost:${PHPMYADMIN_PORT}"
    echo -e "${BLUE}MySQL Host:${NC}      localhost:${MYSQL_57_PORT}"
    echo -e "${BLUE}MySQL User:${NC}      ${MYSQL_57_USER}"
    echo -e "${BLUE}MySQL Database:${NC}  ${MYSQL_57_DATABASE}"
    echo ""
}

mount_project() {
    local project_path="$1"
    local php_version="$2"
    local project_name="${3:-project}"

    if [ -z "$project_path" ] || [ -z "$php_version" ]; then
        echo -e "${RED}Usage: devstack mount <path> <php74|php82> [name]${NC}"
        return 1
    fi

    # Resolve project path
    if [ "$project_path" = "." ]; then
        project_path="$(pwd)"
    else
        # Convert to absolute path if relative
        if [[ ! "$project_path" = /* ]]; then
            project_path="$(pwd)/$project_path"
        fi
        # Resolve path
        project_path="$(cd "$project_path" 2>/dev/null && pwd || echo "")"
        if [ -z "$project_path" ]; then
            echo -e "${RED}Error: Directory does not exist${NC}"
            return 1
        fi
    fi

    # Validate project path exists
    if [ ! -d "$project_path" ]; then
        echo -e "${RED}Error: Directory $project_path does not exist${NC}"
        return 1
    fi

    # Validate PHP version
    if [ "$php_version" != "php74" ] && [ "$php_version" != "php82" ]; then
        echo -e "${RED}Error: PHP version must be 'php74' or 'php82'${NC}"
        return 1
    fi

    # Create a configuration file to track mounted projects
    local projects_file="$SCRIPT_DIR/.devstack_projects"

    # Check if project is already mounted
    if [ -f "$projects_file" ] && grep -q "^$php_version:$project_name:" "$projects_file"; then
        echo -e "${YELLOW}Warning: $project_name already exists in $php_version${NC}"
        echo -e "${YELLOW}Use 'devstack unmount $php_version $project_name' first${NC}"
        return 1
    fi

    echo -e "${BLUE}Mounting project with Docker bind mount...${NC}"

    # Add project configuration to tracking file
    echo "$php_version:$project_name:$project_path" >> "$projects_file"

    # Restart the specific container with the new mount
    restart_container_with_project "$php_version"

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Project mounted successfully!${NC}"
        echo -e "${BLUE}Source:      ${NC}$project_path"
        echo -e "${BLUE}Mounted as:  ${NC}$project_name"

        # Determine the port based on PHP version
        if [ "$php_version" = "php74" ]; then
            local port="${PHP_74_PORT}"
        else
            local port="${PHP_82_PORT}"
        fi

        echo -e "${GREEN}Access at:   ${NC}http://localhost:$port/$project_name/"
        echo ""
        echo -e "${GREEN}✓ Real-time editing enabled - changes reflect immediately${NC}"

        return 0
    else
        # Remove from tracking file if mounting failed
        if [ -f "$projects_file" ]; then
            grep -v "^$php_version:$project_name:" "$projects_file" > "${projects_file}.tmp" && mv "${projects_file}.tmp" "$projects_file"
        fi
        echo -e "${RED}Error: Failed to mount project${NC}"
        return 1
    fi
}

restart_container_with_project() {
    local php_version="$1"
    local container_name
    local projects_file="$SCRIPT_DIR/.devstack_projects"

    if [ "$php_version" = "php74" ]; then
        container_name="${PHP74_CONTAINER_NAME}"
    else
        container_name="${PHP82_CONTAINER_NAME}"
    fi

    echo -e "${BLUE}Restarting $container_name with mounted projects...${NC}"

    # Stop the container
    docker stop "$container_name" >/dev/null 2>&1
    docker rm "$container_name" >/dev/null 2>&1

    # Build docker run command with all project mounts
    local docker_cmd="docker run -d --name $container_name"
    docker_cmd="$docker_cmd --network ${NETWORK_NAME}"

    # Add main www directory mount
    docker_cmd="$docker_cmd -v $SCRIPT_DIR/www/$php_version:/var/www/html"

    # Add project mounts from tracking file
    if [ -f "$projects_file" ]; then
        while IFS=':' read -r version link_name project_path; do
            if [ "$version" = "$php_version" ]; then
                docker_cmd="$docker_cmd -v $project_path:/var/www/html/$link_name"
            fi
        done < "$projects_file"
    fi

    # Add port mapping
    if [ "$php_version" = "php74" ]; then
        docker_cmd="$docker_cmd -p ${PHP_74_PORT}:80"
        docker_cmd="$docker_cmd devstack-php74:latest"
    else
        docker_cmd="$docker_cmd -p ${PHP_82_PORT}:80"
        docker_cmd="$docker_cmd devstack-php82:latest"
    fi

    # Execute the docker run command
    eval "$docker_cmd" >/dev/null 2>&1

    # Wait for container to be ready
    sleep 3

    # Check if container is running
    if docker ps | grep -q "$container_name"; then
        return 0
    else
        return 1
    fi
}

unmount_project() {
    local php_version="$1"
    local project_name="${2:-project}"

    if [ -z "$php_version" ]; then
        echo -e "${RED}Usage: devstack unmount <php_version> [project_name]${NC}"
        return 1
    fi

    # Validate PHP version
    if [ "$php_version" != "php74" ] && [ "$php_version" != "php82" ]; then
        echo -e "${RED}Error: PHP version must be 'php74' or 'php82'${NC}"
        return 1
    fi

    local projects_file="$SCRIPT_DIR/.devstack_projects"

    # Check if project exists in tracking file
    if [ ! -f "$projects_file" ] || ! grep -q "^$php_version:$project_name:" "$projects_file"; then
        echo -e "${YELLOW}No mounted project found: $project_name in $php_version${NC}"
        return 1
    fi

    echo -e "${BLUE}Unmounting project $project_name from $php_version...${NC}"

    # Remove from tracking file
    grep -v "^$php_version:$project_name:" "$projects_file" > "${projects_file}.tmp" || true
    mv "${projects_file}.tmp" "$projects_file"
    echo -e "${YELLOW}Removed from tracking file${NC}"

    # Restart container without the mount
    restart_container_with_project "$php_version"

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Project unmounted successfully!${NC}"
        echo -e "${BLUE}Removed:${NC} $project_name from $php_version"
    else
        echo -e "${RED}Error: Failed to unmount project${NC}"
        return 1
    fi
}

list_projects() {
    local php_version="$1"
    local projects_file="$SCRIPT_DIR/.devstack_projects"

    if [ -z "$php_version" ]; then
        echo -e "${BLUE}DevStack Mounted Projects:${NC}"
        echo ""

        # Show mounted projects from tracking file
        if [ -f "$projects_file" ] && [ -s "$projects_file" ]; then
            for version in php74 php82; do
                echo -e "${YELLOW}$version:${NC}"
                local found_projects=false

                while IFS=':' read -r file_version project_name project_path; do
                    if [ "$file_version" = "$version" ]; then
                        echo -e "  ${GREEN}$project_name${NC} -> $project_path"
                        found_projects=true
                    fi
                done < "$projects_file"

                if [ "$found_projects" = false ]; then
                    echo -e "  ${YELLOW}No mounted projects${NC}"
                fi
                echo ""
            done
        else
            echo -e "${YELLOW}No mounted projects found${NC}"
        fi
    else
        # Show projects for specific PHP version
        echo -e "${BLUE}Mounted projects for $php_version:${NC}"

        if [ -f "$projects_file" ] && [ -s "$projects_file" ]; then
            local found_projects=false

            while IFS=':' read -r file_version project_name project_path; do
                if [ "$file_version" = "$php_version" ]; then
                    echo -e "  ${GREEN}$project_name${NC} -> $project_path"
                    found_projects=true
                fi
            done < "$projects_file"

            if [ "$found_projects" = false ]; then
                echo -e "  ${YELLOW}No mounted projects${NC}"
            fi
        else
            echo -e "  ${YELLOW}No mounted projects${NC}"
        fi
    fi
}

# Main script logic
case ${1:-help} in
    start)
        start_services
        ;;
    stop)
        stop_services
        ;;
    restart)
        restart_services
        ;;
    build)
        build_services
        ;;
    logs)
        show_logs
        ;;
    status)
        show_status
        ;;
    clean)
        clean_everything
        ;;
    php74)
        access_php74
        ;;
    php82)
        access_php82
        ;;
    mysql)
        access_mysql
        ;;
    info)
        show_info
        ;;
    mount)
        mount_project "$2" "$3" "$4"
        ;;
    unmount)
        unmount_project "$2" "$3"
        ;;
    mounts)
        list_projects "$2"
        ;;
    help|*)
        print_help
        ;;
esac