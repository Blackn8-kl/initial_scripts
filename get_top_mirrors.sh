#!/bin/bash

# Define colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if the user is running the script as root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Please run this script as root.${NC}"
  exit 1
fi

# Location to save the new mirrorlist
mirrorlist_file="/etc/pacman.d/mirrorlist"

# Location to save a backup of the old mirrorlist
backup_file="/etc/pacman.d/mirrorlist.backup"

# Number of mirrors to include in the new mirrorlist
mirror_count=10

echo -e "${YELLOW}Creating a backup of the current mirrorlist...${NC}"

# Backup the existing mirrorlist
cp "$mirrorlist_file" "$backup_file"

if [ $? -eq 0 ]; then
  echo -e "${GREEN}Backup created successfully.${NC}"
else
  echo -e "${RED}Error creating backup.${NC}"
  exit 1
fi

# Check if reflector is installed and install it if not
if ! command -v reflector &> /dev/null; then
  echo -e "${YELLOW}Installing reflector...${NC}"
  pacman -S reflector --noconfirm
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}Reflector installed successfully.${NC}"
  else
    echo -e "${RED}Error installing reflector.${NC}"
    exit 1
  fi
fi


echo -e "${YELLOW}Updating Arch Linux mirrorlist...${NC}"

# Use reflector to generate and save a new mirrorlist
reflector --latest $mirror_count --protocol https --sort rate --save "$mirrorlist_file"

if [ $? -eq 0 ]; then
  echo -e "${GREEN}Mirrorlist updated successfully.${NC}"
else
  echo -e "${RED}Error updating mirrorlist.${NC}"
  exit 1
fi

# Update the package database and upgrade the system
echo -e "${YELLOW}Updating package database and upgrading the system...${NC}"
pacman -Syu

echo -e "${GREEN}Script completed.${NC}"

