#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m'

TARGET_DIR="/var/www/pterodactyl"

# --- UI FUNCTIONS ---
print_header() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN} $1 ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

print_status() { echo -e "${YELLOW}⏳ $1...${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }

animate_progress() {
    local pid=$1
    local message=$2
    local delay=0.1
    local spinstr='|/-\'
    print_status "$message"
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# --- MASTER INSTALLER ENGINE ---
install_theme() {
    local theme_name=$1
    local url=$2
    local filename=$3

    print_header "INSTALLING $theme_name"
    
    cd "$TARGET_DIR" || { print_error "Pterodactyl folder not found!"; return; }

    # 1. Download
    print_status "Downloading $filename"
    curl -LO "$url" > /dev/null 2>&1 &
    animate_progress $! "Downloading from source"
    
    if [ ! -f "$filename" ]; then
        print_error "Download failed! Link might be expired."
        read -p "Press Enter to return..."
        return
    fi

    # 2. Installation Logic
    if [[ "$filename" == *.blueprint ]]; then
        print_status "Running Blueprint Tool..."
        # Auto-confirm with 'yes'
        yes | blueprint -i "$filename" > /dev/null 2>&1 &
        animate_progress $! "Blueprint Installing"
        print_success "$theme_name is now installed!"
    else
        print_status "Extracting ZIP content..."
        unzip -o "$filename" -d "$TARGET_DIR" > /dev/null 2>&1
        print_status "Clearing Panel Cache..."
        php artisan view:clear && php artisan cache:clear
        print_success "$theme_name files extracted and cache cleared!"
    fi

    echo -e "\n${YELLOW}Press Enter to return to Main Menu...${NC}"
    read
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
    echo -e "  ${WHITE}[1]${NC} Euphoria Theme      ${WHITE}[6]${NC} Unix Theme (ZIP)"
    echo -e "  ${WHITE}[2]${NC} Nebula Theme        ${WHITE}[7]${NC} Stellar Theme (ZIP)"
    echo -e "  ${WHITE}[3]${NC} Nook Theme          ${WHITE}[8]${NC} REvivatyl (ZIP)"
    echo -e "  ${WHITE}[4]${NC} Arix Theme (ZIP)    ${WHITE}[9]${NC} Futuristic (ZIP)"
    echo -e "  ${WHITE}[5]${NC} Admin L/D (ZIP)     ${WHITE}[0]${NC} Exit Manager"
    echo -e ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -n "  Select a theme [0-9]: "
    read choice

    case $choice in
        1) install_theme "Euphoria" "https://github.com/MrRangerXD/Pterodactyl-Themes/raw/refs/heads/main/euphoriatheme.blueprint" "euphoriatheme.blueprint" ;;
        2) run_remote_script "https://raw.githubusercontent.com/MrRangerXD/VPS/refs/heads/main/cd/th2.sh" ;;
        3) install_theme "Nook" "https://github.com/MrRangerXD/Pterodactyl-Themes/raw/refs/heads/main/nooktheme.blueprint" "nooktheme.blueprint" ;;
        4) install_theme "Arix" "https://github.com/MrRangerXD/Pterodactyl-Themes/raw/refs/heads/main/arix-v1.3.1.zip" "arix.zip" ;;
        5) install_theme "Admin L/D" "https://github.com/MrRangerXD/Pterodactyl-Themes/raw/refs/heads/main/admin_themelightdark_2.9.zip" "admin.zip" ;;
        6) install_theme "Unix" "https://github.com/MrRangerXD/Pterodactyl-Themes/raw/refs/heads/main/UnixTheme-v2.71.zip" "unix.zip" ;;
        7) install_theme "Stellar" "https://github.com/MrRangerXD/Pterodactyl-Themes/raw/refs/heads/main/Stellar_v3.4.zip" "stellar.zip" ;;
        8) install_theme "REvivatyl" "https://github.com/MrRangerXD/Pterodactyl-Themes/raw/refs/heads/main/REvivatyl-2.1.1.zip" "revivatyl.zip" ;;
        9) install_theme "Futuristic" "https://github.com/MrRangerXD/Pterodactyl-Themes/raw/refs/heads/main/Futuristic%20Theme.zip" "futuristic.zip" ;;
        0) exit 0 ;;
        *) print_error "Invalid selection!"; sleep 1 ;;
    esac
done
