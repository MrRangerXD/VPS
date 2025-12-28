#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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

# --- INSTALLATION LOGIC ---
install_process() {
    local name=$1
    local url=$2
    local file=$3

    print_header "STARTING $name INSTALLATION"
    
    if [ ! -d "$TARGET_DIR" ]; then
        print_error "Pterodactyl directory not found at $TARGET_DIR"
        return
    fi

    cd "$TARGET_DIR" || exit

    # Download Step
    print_status "Downloading $file"
    curl -LO "$url" > /dev/null 2>&1 &
    animate_progress $! "Downloading"
    
    if [ -f "$file" ]; then
        print_success "Download Complete."
        
        # Check if it's a .blueprint file or a .zip
        if [[ "$file" == *.blueprint ]]; then
            print_status "Running Blueprint Installer"
            blueprint -i "$file" > /dev/null 2>&1 &
            animate_progress $! "Installing via Blueprint"
            print_success "$name is now installed!"
        else
            print_warning "$file is a ZIP file. It has been downloaded to $TARGET_DIR."
            print_warning "Please manually unzip if it is a legacy theme."
        fi
    else
        print_error "Failed to download the file."
    fi
    
    echo -e "\n${YELLOW}Press Enter to return to menu...${NC}"
    read
}

# --- MAIN MENU ---
while true; do
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}"
    echo "       ______                  _ _______        _          "          
    echo "      |___  /                 (_)__   __|      | |         "            
    echo "         / / ___ _ __  ___  ___ _   | | ___  ___| |__      "          
    echo "        / / / _ \ '_ \/ __|/ _ \ |  | |/ _ \/ __| '_ \     "          
    echo "       / /_|  __/ | | \__ \  __/ |  | |  __/ (__| | | |    "            
    echo "      /_____\___|_| |_|___/\___|_|  |_|\___|\___|_| |_|    "
    echo -e "${NC}"
    echo -e "${CYAN}             THEMES MADE BY ZENSEITECH${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    echo -e "  ${WHITE}[1]${NC} Euphoria Theme       ${WHITE}[6]${NC} Unix Theme (ZIP)"
    echo -e "  ${WHITE}[2]${NC} Nebula Theme         ${WHITE}[7]${NC} Stellar Theme (ZIP)"
    echo -e "  ${WHITE}[3]${NC} Nook Theme           ${WHITE}[8]${NC} REvivatyl (ZIP)"
    echo -e "  ${WHITE}[4]${NC} Arix Theme (ZIP)     ${WHITE}[9]${NC} Futuristic Theme (ZIP)"
    echo -e "  ${WHITE}[5]${NC} Admin Light/Dark     ${WHITE}[0]${NC} Exit Manager"
    echo -e ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -n "  Select a theme [0-9]: "
    read choice

    case $choice in
        1) install_process "Euphoria" "https://github.com/MrRangerXD/Pterodactyl-Themes/raw/refs/heads/main/euphoriatheme.blueprint" "euphoriatheme.blueprint" ;;
        2) install_process "Nebula" "https://github.com/MrRangerXD/Pterodactyl-Themes/raw/refs/heads/main/nebula.blueprint" "nebula.blueprint" ;;
        3) install_process "Nook" "https://github.com/MrRangerXD/Pterodactyl-Themes/raw/refs/heads/main/nooktheme.blueprint" "nooktheme.blueprint" ;;
        4) install_process "Arix" "https://github.com/MrRangerXD/Pterodactyl-Themes/raw/refs/heads/main/arix-v1.3.1.zip" "arix-v1.3.1.zip" ;;
        5) install_process "Admin LightDark" "https://github.com/MrRangerXD/Pterodactyl-Themes/raw/refs/heads/main/admin_themelightdark_2.9.zip" "admin_themelightdark_2.9.zip" ;;
        6) install_process "Unix Theme" "https://github.com/MrRangerXD/Pterodactyl-Themes/raw/refs/heads/main/UnixTheme-v2.71.zip" "UnixTheme-v2.71.zip" ;;
        7) install_process "Stellar" "https://github.com/MrRangerXD/Pterodactyl-Themes/raw/refs/heads/main/Stellar_v3.4.zip" "Stellar_v3.4.zip" ;;
        8) install_process "REvivatyl" "https://github.com/MrRangerXD/Pterodactyl-Themes/raw/refs/heads/main/REvivatyl-2.1.1.zip" "REvivatyl-2.1.1.zip" ;;
        9) install_process "Futuristic" "https://github.com/MrRangerXD/Pterodactyl-Themes/raw/refs/heads/main/Futuristic%20Theme.zip" "Futuristic_Theme.zip" ;;
        0) exit 0 ;;
        *) print_error "Invalid selection!"; sleep 1 ;;
    esac
done
