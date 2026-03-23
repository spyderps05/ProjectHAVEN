#!/bin/bash

# Project H.A.V.E.N. Uninstall Script

###################################################################################################################################################################################################

# Script                | Project H.A.V.E.N. Uninstall Script
# Version               | 1.0.0
# Author                | Crosstalk Solutions, LLC
# Website               | https://crosstalksolutions.com

###################################################################################################################################################################################################
#                                                                                                                                                                                                 #
#                                                                                  Constants & Variables                                                                                          #
#                                                                                                                                                                                                 #
###################################################################################################################################################################################################

HAVEN_DIR="/opt/project-haven"
MANAGEMENT_COMPOSE_FILE="${HAVEN_DIR}/compose.yml"

###################################################################################################################################################################################################
#                                                                                                                                                                                                 #
#                                                                                     Functions                                                                                                   #
#                                                                                                                                                                                                 #
###################################################################################################################################################################################################

check_has_sudo() {
  if sudo -n true 2>/dev/null; then
    echo -e "${GREEN}#${RESET} User has sudo permissions.\\n"
  else
    echo "User does not have sudo permissions"
    header_red
    echo -e "${RED}#${RESET} This script requires sudo permissions to run. Please run the script with sudo.\\n"
    echo -e "${RED}#${RESET} For example: sudo bash $(basename "$0")"
    exit 1
  fi
}

check_current_directory(){
  if [ "$(pwd)" == "${HAVEN_DIR}" ]; then
    echo "Please run this script from a directory other than ${HAVEN_DIR}."
    exit 1
  fi
}

ensure_management_compose_file_exists(){
  if [ ! -f "${MANAGEMENT_COMPOSE_FILE}" ]; then
    echo "Unable to find the management Docker Compose file at ${MANAGEMENT_COMPOSE_FILE}. There may be a problem with your Project H.A.V.E.N. installation."
    exit 1
  fi
}

get_uninstall_confirmation(){
  read -p "This script will remove ALL Project H.A.V.E.N. files and containers. THIS CANNOT BE UNDONE. Are you sure you want to continue? (y/n): " choice
  case "$choice" in
    y|Y )
      echo -e "User chose to continue with the uninstallation."
      ;;
    n|N )
      echo -e "User chose not to continue with the uninstallation."
      exit 0
      ;;
    * )
      echo "Invalid Response"
      echo "User chose not to continue with the uninstallation."
      exit 0
      ;;
  esac
}

ensure_docker_installed() {
    if ! command -v docker &> /dev/null; then
        echo "Unable to find Docker. There may be a problem with your Docker installation."
        exit 1
    fi
}

check_docker_compose() {
  # Check if 'docker compose' (v2 plugin) is available
  if ! docker compose version &>/dev/null; then
    echo -e "${RED}#${RESET} Docker Compose v2 is not installed or not available as a Docker plugin."
    echo -e "${YELLOW}#${RESET} This script requires 'docker compose' (v2), not 'docker-compose' (v1)."
    echo -e "${YELLOW}#${RESET} Please read the Docker documentation at https://docs.docker.com/compose/install/ for instructions on how to install Docker Compose v2."
    exit 1
  fi
}

storage_cleanup() {
  read -p "Do you want to delete the Project H.A.V.E.N. storage directory (${HAVEN_DIR})? This is best if you want to start a completely fresh install. This will PERMANENTLY DELETE all stored Haven data and can't be undone! (y/N): " delete_dir_choice
  case "$delete_dir_choice" in
      y|Y )
          echo "Removing Project H.A.V.E.N. files..."
          if rm -rf "${HAVEN_DIR}"; then
              echo "Project H.A.V.E.N. files removed."
          else
              echo "Warning: Failed to fully remove ${HAVEN_DIR}. You may need to remove it manually."
          fi
          ;;
      * )
          echo "Skipping removal of ${HAVEN_DIR}."
          ;;
  esac
}

uninstall_haven() {
    echo "Stopping and removing Project H.A.V.E.N. management containers..."
    docker compose -p project-haven -f "${MANAGEMENT_COMPOSE_FILE}" down
    echo "Allowing some time for management containers to stop..."
    sleep 5


    # Stop and remove all containers where name starts with "haven_"
    echo "Stopping and removing all Project H.A.V.E.N. app containers..."
    docker ps -a --filter "name=^haven_" --format "{{.Names}}" | xargs -r docker rm -f
    echo "Allowing some time for app containers to stop..."
    sleep 5

    echo "Containers should be stopped now."

    # Remove the shared Docker network (may still exist if app containers were using it during compose down)
    echo "Removing project-haven_default network if it exists..."
    docker network rm project-haven_default 2>/dev/null && echo "Network removed." || echo "Network already removed or not found."

    # Remove the shared update volume
    echo "Removing project-haven_haven-update-shared volume if it exists..."
    docker volume rm project-haven_haven-update-shared 2>/dev/null && echo "Volume removed." || echo "Volume already removed or not found."

    # Prompt user for storage cleanup and handle it if so
    storage_cleanup

    echo "Project H.A.V.E.N. has been uninstalled. We hope to see you again soon!"
}

###################################################################################################################################################################################################
#                                                                                                                                                                                                 #
#                                                                                       Main                                                                                                      #
#                                                                                                                                                                                                 #
###################################################################################################################################################################################################
check_has_sudo
check_current_directory
ensure_management_compose_file_exists
ensure_docker_installed
check_docker_compose
get_uninstall_confirmation
uninstall_haven