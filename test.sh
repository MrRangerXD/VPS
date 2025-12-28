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

    # 1. CLEAN UP PREVIOUS FAILURES
    rm -f "$filename"
    rm -f "${name,,}.zip"
    rm -f "${name,,}.blueprint"

    # 2. DOWNLOAD
    echo -e "${YELLOW}Downloading $name...${NC}"
    curl -fSL -o "$filename" "$url"
    
    if [ ! -s "$filename" ]; then
        echo -e "${RED}Download failed!${NC}"
        read -p "Press Enter..."
        return
    fi

    # 3. FIX THE ZIP ERROR (The renaming trick)
    # Blueprint often looks for [name].zip even if the file is a .blueprint
    if [[ "$filename" == *.blueprint ]]; then
        cp "$filename" "${filename%.blueprint}.zip"
    fi

    # 4. EXECUTE INSTALLATION
    if [[ "$filename" == *.blueprint ]]; then
        echo -e "${GREEN}Running Blueprint Installer...${NC}"
        # We pass the name without extension so Blueprint finds its own zip
        yes y | blueprint -i "${filename%.blueprint}"
    else
        echo -e "${GREEN}Extracting ZIP Theme...${NC}"
        unzip -o "$filename" -d "$TARGET_DIR"
        php artisan view:clear && php artisan cache:clear
    fi

    # 5. CLEAN UP AFTER INSTALL
    rm -f "${filename%.blueprint}.zip"

    echo -e "${GREEN}✅ $name Installation Finished!${NC}"
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
    echo -e "  [1] Euphoria (Blueprint)  [6] Unix Theme (ZIP)"
    echo -e "  [2] Nebula (FIXED)        [7] Stellar Theme (ZIP)"
    echo -e "  [3] Nook Theme            [8] REvivatyl (ZIP)"
    echo -e "  [4] Arix (ZIP)            [9] Futuristic (ZIP)"
    echo -e "  [5] Admin L/D (ZIP)       [0] Exit Manager"
    echo -e ""
    echo -n "  Select theme: "
    read choice

    case $choice in
        1) install_theme "Euphoria" "https://github.com/MrRangerXD/Pterodactyl-Themes/raw/refs/heads/main/euphoriatheme.blueprint" "euphoriatheme.blueprint" ;;
        2) install_theme "Nebula" "https://github.com/MrRangerXD/Pterodactyl-Themes/raw/refs/heads/main/nebula.blueprint" "nebula.blueprint" ;;
        3) install_theme "Nook" "https://github.com/MrRangerXD/Pterodactyl-Themes/raw/refs/heads/main/nooktheme.blueprint" "nooktheme.blueprint" ;;
        4) install_theme "Arix" "https://github.com/MrRangerXD/Pterodactyl-Themes/raw/refs/heads/main/arix-v1.3.1.zip" "arix.zip" ;;
        5) install_theme "Admin L/D" "https://github.com/MrRangerXD/Pterodactyl-Themes/raw/refs/heads/main/admin_themelightdark_2.9.zip" "admin.zip" ;;
        6) install_theme "Unix" "https://github.com/MrRangerXD/Pterodactyl-Themes/raw/refs/heads/main/UnixTheme-v2.71.zip" "unix.zip" ;;
        7) install_theme "Stellar" "https://github.com/MrRangerXD/Pterodactyl-Themes/raw/refs/heads/main/Stellar_v3.4.zip" "stellar.zip" ;;
        8) install_theme "REvivatyl" "https://github.com/MrRangerXD/Pterodactyl-Themes/raw/refs/heads/main/REvivatyl-2.1.1.zip" "revivatyl.zip" ;;
        9) install_theme "Futuristic" "https://github.com/MrRangerXD/Pterodactyl-Themes/raw/refs/heads/main/Futuristic%20Theme.zip" "futuristic.zip" ;;
        0) exit 0 ;;
    esac
done
