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
    echo "  start       Start all services"
    echo "  stop        Stop all services"
    echo "  restart     Restart all services"
    echo "  build       Build/rebuild all services"
    echo "  logs        Show logs from all services"
    echo "  status      Show status of all services"
    echo "  clean       Remove all containers and volumes (DESTRUCTIVE)"
    echo "  php74       Access PHP 7.4 container shell"
    echo "  php82       Access PHP 8.2 container shell"
    echo "  mysql       Access MySQL shell"
    echo "  info        Show service URLs and information"
    echo "  help        Show this help message"
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
    help|*)
        print_help
        ;;
esac