print_header_rule
big_header "MINECRAFT PLAYER MANAGER"
print_header_rule
echo -e "${CYAN}Running: ${BOLD}Minecraft Player Manager Setup${NC}"
print_header_rule

check_curl

print_status "Downloading blueprints..."
cd
cd /var/www/pterodactyl
wget -q https://github.com/MrRangerXD/Free123/raw/refs/heads/main/minecraftplayermanager.blueprint
wget -q https://github.com/MrRangerXD/Free123/raw/refs/heads/main/mcplugins.blueprint
print_success "Blueprints downloaded"

print_status "Installing mcplugins.blueprint..."
blueprint -i mcplugins.blueprint && print_success "mcplugins installed"

print_status "Installing minecraftplayermanager.blueprint..."
blueprint -i minecraftplayermanager.blueprint && print_success "Minecraft Player Manager installed"

echo -e ""
read -p "$(echo -e "${YELLOW}Press Enter to continue...${NC}")" -n 1
;;
