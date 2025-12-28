#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

TARGET_DIR="/var/www/pterodactyl"

# --- THE FIX ENGINE ---
install_theme() {
    local name=$1
    local url=$2
    local filename=$3

    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN} STARTING INSTALLATION: $name ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    cd "$TARGET_DIR" || { echo -e "${RED}Error: Pterodactyl folder not found!${NC}"; return; }

    # 1. CLEAN UP PREVIOUS BROKEN DOWNLOADS
    rm -f "$filename"
    rm -f "${filename%.blueprint}.zip"
    rm -rf ".blueprint/tmp" # Clears blueprint's internal cache

    # 2. DOWNLOAD (Using the new Raw structure)
    echo -e "${YELLOW}Downloading $name from stable source...${NC}"
    # -f fails on 404, -L follows redirects, -s is silent, -S shows errors
    curl -fSL -o "$filename" "$url"
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}Download failed again! (404 Error)${NC}"
        echo -e "${YELLOW}Check if your server can reach github.com${NC}"
        read -p "Press Enter to return..."
        return
    fi

    # 3. BLUEPRINT PREP
    if [[ "$filename" == *.blueprint ]]; then
        # Force a zip copy for the Blueprint extractor
        cp "$filename" "${filename%.blueprint}.zip"
        echo -e "${GREEN}Running Blueprint Installer...${NC}"
        # Automatically say 'y' to the prompt
        yes y | blueprint -i "${filename%.blueprint}"
    else
        echo -e "${GREEN}Extracting ZIP Theme...${NC}"
        unzip -o "$filename" -d "$TARGET_DIR"
        php artisan view:clear && php artisan cache:clear
    fi

    # 4. FINAL CLEANUP
    rm -f "${filename%.blueprint}.zip"
    echo -e "${GREEN}✅ Installation Finished! Refresh your panel.${NC}"
    read -p "Press Enter to return to menu..."
}

# --- MAIN MENU ---
while true; do
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}"
    echo "      ______                   _ _______        _          "          
    echo "      |___  /                 (_)__   __|      | |         "            
    echo "         / / ___ _ __  ___  ___ _   | | ___  ___| |__      "          
    echo "        / / / _ \ '_ \/ __|/ _ \ |  | |/ _ \/ __| '_ \     "          
    echo "       / /_|  __/ | | \__ \  __/ |  | |  __/ (__| | | |    "            
    echo "      /_____\___|_| |_|___/\___|_|  |_|\___|\___|_| |_|    "
    echo -e "${NC}"
    echo -e "${CYAN}             THEMES MADE BY ZENSEITECH${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    # These links are now fixed to bypass the 404
    echo -e "  [1] Euphoria (Blueprint)"
    echo -e "  [2] Nebula (FIXED)"
    echo -e "  [3] Nook Theme"
    echo -e "  [0] Exit"
    echo -e ""
    echo -n "  Select theme: "
    read choice

    case $choice in
        1) install_theme "Euphoria" "https://raw.githubusercontent.com/MrRangerXD/Pterodactyl-Themes/main/euphoriatheme.blueprint" "euphoriatheme.blueprint" ;;
        2) install_theme "Nebula" "https://raw.githubusercontent.com/MrRangerXD/Pterodactyl-Themes/main/nebula.blueprint" "nebula.blueprint" ;;
        3) install_theme "Nook" "https://raw.githubusercontent.com/MrRangerXD/Pterodactyl-Themes/main/nooktheme.blueprint" "nooktheme.blueprint" ;;
        0) exit 0 ;;
        *) echo -e "${RED}Invalid Selection!${NC}"; sleep 1 ;;
    esac
done
