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

    # 1. CLEAN UP
    rm -f "$filename"
    rm -f "${filename%.blueprint}.zip"

    # 2. DOWNLOAD (Using direct raw links)
    echo -e "${YELLOW}Downloading $name from source...${NC}"
    curl -fSLo "$filename" "$url"
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}Download failed! (Error 404 or Connection Issue)${NC}"
        echo -e "${YELLOW}The link might have changed. Try Option 1 or 3.${NC}"
        read -p "Press Enter to return..."
        return
    fi

    # 3. BLUEPRINT PREP
    if [[ "$filename" == *.blueprint ]]; then
        cp "$filename" "${filename%.blueprint}.zip"
        echo -e "${GREEN}Running Blueprint Installer...${NC}"
        yes y | blueprint -i "${filename%.blueprint}"
    else
        echo -e "${GREEN}Extracting ZIP Theme...${NC}"
        unzip -o "$filename" -d "$TARGET_DIR"
        php artisan view:clear && php artisan cache:clear
    fi

    rm -f "${filename%.blueprint}.zip"
    echo -e "${GREEN}✅ Process finished!${NC}"
    read -p "Press Enter to return to menu..."
}

# --- MAIN MENU ---
while true; do
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}             THEMES MADE BY ZENSEITECH${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    # I updated these specific links to the raw format
    echo -e "  [1] Euphoria (Blueprint)"
    echo -e "  [2] Nebula (Official Raw Link)"
    echo -e "  [3] Nook Theme (Blueprint)"
    echo -e "  [0] Exit"
    echo -e ""
    echo -n "  Select theme: "
    read choice

    case $choice in
        1) install_theme "Euphoria" "https://raw.githubusercontent.com/MrRangerXD/Pterodactyl-Themes/main/euphoriatheme.blueprint" "euphoriatheme.blueprint" ;;
        2) install_theme "Nebula" "https://raw.githubusercontent.com/MrRangerXD/Pterodactyl-Themes/main/nebula.blueprint" "nebula.blueprint" ;;
        3) install_theme "Nook" "https://raw.githubusercontent.com/MrRangerXD/Pterodactyl-Themes/main/nooktheme.blueprint" "nooktheme.blueprint" ;;
        0) exit 0 ;;
    esac
done
