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
    echo "  start                       Start all services"
    echo "  stop                        Stop all services"
    echo "  restart                     Restart all services"
    echo "  build                       Build/rebuild all services"
    echo "  logs                        Show logs from all services"
    echo "  status                      Show status of all services"
    echo "  clean                       Remove all containers and volumes (DESTRUCTIVE)"
    echo "  link <path> <php> [name]    Create symlink to project"
    echo "  unlink <php> [name]         Remove symlink"
    echo "  links [php]                 List all symlinks"
    echo "  php74                       Access PHP 7.4 container shell"
    echo "  php82                       Access PHP 8.2 container shell"
    echo "  mysql                       Access MySQL shell"
    echo "  info                        Show service URLs and information"
    echo "  help                        Show this help message"
    echo ""
    echo "Examples:"
    echo "  devstack link . php74                    # Link current dir as 'project'"
    echo "  devstack link ~/Projects/blog php82 blog # Link with custom name"
    echo "  devstack unlink php74                    # Remove 'project' link"
    echo "  devstack links                           # Show all links"
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

link_project() {
    local project_path="$1"
    local php_version="$2"
    local link_name="${3:-project}"
    
    if [ -z "$project_path" ] || [ -z "$php_version" ]; then
        echo -e "${RED}Usage: devstack link <project_path> <php_version> [link_name]${NC}"
        echo -e "${YELLOW}Examples:${NC}"
        echo -e "  devstack link . php74                    # Current directory as 'project'"
        echo -e "  devstack link /path/to/myapp php82       # Specific path as 'project'"
        echo -e "  devstack link ~/Projects/blog php74 blog # Custom link name"
        return 1
    fi
    
    # Validate PHP version
    if [ "$php_version" != "php74" ] && [ "$php_version" != "php82" ]; then
        echo -e "${RED}Error: PHP version must be 'php74' or 'php82'${NC}"
        return 1
    fi
    
    # Resolve absolute path
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
    
    local target_dir="$SCRIPT_DIR/www/$php_version/$link_name"
    
    # Remove existing link/directory if it exists
    if [ -L "$target_dir" ]; then
        rm "$target_dir"
        echo -e "${YELLOW}Removed existing symlink${NC}"
    elif [ -d "$target_dir" ]; then
        echo -e "${RED}Error: Directory $target_dir already exists (not a symlink)${NC}"
        echo -e "${YELLOW}Please remove it manually or use a different link name${NC}"
        return 1
    fi
    
    # Create symlink
    ln -s "$project_path" "$target_dir"
    
    echo -e "${GREEN}Project linked successfully!${NC}"
    echo -e "${BLUE}Source:${NC}      $project_path"
    echo -e "${BLUE}Linked to:${NC}   $target_dir"
    
    # Show access URL
    if [ "$php_version" = "php74" ]; then
        echo -e "${GREEN}Access at:${NC}   http://localhost:${PHP_74_PORT}/$link_name/"
    else
        echo -e "${GREEN}Access at:${NC}   http://localhost:${PHP_82_PORT}/$link_name/"
    fi
}

unlink_project() {
    local php_version="$1"
    local link_name="${2:-project}"
    
    if [ -z "$php_version" ]; then
        echo -e "${RED}Usage: devstack unlink <php_version> [link_name]${NC}"
        echo -e "${YELLOW}Examples:${NC}"
        echo -e "  devstack unlink php74          # Remove 'project' link"
        echo -e "  devstack unlink php82 blog     # Remove 'blog' link"
        return 1
    fi
    
    # Validate PHP version
    if [ "$php_version" != "php74" ] && [ "$php_version" != "php82" ]; then
        echo -e "${RED}Error: PHP version must be 'php74' or 'php82'${NC}"
        return 1
    fi
    
    local target_dir="$SCRIPT_DIR/www/$php_version/$link_name"
    
    if [ -L "$target_dir" ]; then
        rm "$target_dir"
        echo -e "${GREEN}Project unlinked successfully!${NC}"
        echo -e "${BLUE}Removed:${NC} $target_dir"
    elif [ -d "$target_dir" ]; then
        echo -e "${YELLOW}Warning: $target_dir is a directory, not a symlink${NC}"
        echo -e "${YELLOW}Use 'rm -rf $target_dir' to remove it manually${NC}"
    else
        echo -e "${YELLOW}No symlink found at $target_dir${NC}"
    fi
}

list_links() {
    local php_version="$1"
    
    if [ -z "$php_version" ]; then
        echo -e "${BLUE}DevStack Project Links:${NC}"
        echo ""
        for version in php74 php82; do
            echo -e "${YELLOW}$version:${NC}"
            local www_dir="$SCRIPT_DIR/www/$version"
            if [ -d "$www_dir" ]; then
                local found_links=false
                for item in "$www_dir"/*; do
                    if [ -L "$item" ]; then
                        local link_name=$(basename "$item")
                        local target=$(readlink "$item")
                        echo -e "  ${GREEN}$link_name${NC} -> $target"
                        found_links=true
                    fi
                done
                if [ "$found_links" = false ]; then
                    echo -e "  ${YELLOW}No symlinks found${NC}"
                fi
            else
                echo -e "  ${YELLOW}Directory not found${NC}"
            fi
            echo ""
        done
    else
        # Show links for specific PHP version
        echo -e "${BLUE}Links for $php_version:${NC}"
        local www_dir="$SCRIPT_DIR/www/$php_version"
        if [ -d "$www_dir" ]; then
            local found_links=false
            for item in "$www_dir"/*; do
                if [ -L "$item" ]; then
                    local link_name=$(basename "$item")
                    local target=$(readlink "$item")
                    echo -e "  ${GREEN}$link_name${NC} -> $target"
                    found_links=true
                fi
            done
            if [ "$found_links" = false ]; then
                echo -e "  ${YELLOW}No symlinks found${NC}"
            fi
        else
            echo -e "  ${YELLOW}Directory not found${NC}"
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
    link)
        link_project "$2" "$3" "$4"
        ;;
    unlink)
        unlink_project "$2" "$3"
        ;;
    links)
        list_links "$2"
        ;;
    help|*)
        print_help
        ;;
esac