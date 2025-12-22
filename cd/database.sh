            print_header_rule
            big_header "DATABASE SETUP"
            print_header_rule
            echo -e "${CYAN}Running: ${BOLD}MySQL / MariaDB Database Setup${NC}"
            print_header_rule

            read -p "Enter new database username: " DB_USER
            read -sp "Enter password for $DB_USER: " DB_PASS
            echo ""
            echo -e "${YELLOW}Creating database user '$DB_USER'...${NC}"

            mysql -u root -p <<MYSQL_SCRIPT
CREATE USER '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON *.* TO '${DB_USER}'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
MYSQL_SCRIPT

            CONF_FILE="/etc/mysql/mariadb.conf.d/50-server.cnf"
            if [ -f "$CONF_FILE" ]; then
                echo -e "${YELLOW}Updating bind-address in $CONF_FILE...${NC}"
                sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' "$CONF_FILE"
            else
                echo -e "${MAGENTA}⚠️  Config file not found: $CONF_FILE${NC}"
            fi

            echo -e "${YELLOW}Restarting MySQL and MariaDB services...${NC}"
            systemctl restart mysql 2>/dev/null
            systemctl restart mariadb 2>/dev/null

            if command -v ufw &>/dev/null; then
                ufw allow 3306/tcp >/dev/null 2>&1 && echo -e "${GREEN}Opened port 3306 for remote connections${NC}"
            fi

            echo -e "${GREEN}✅ Database user '$DB_USER' created and remote access enabled!${NC}"

            echo -e ""
            read -p "$(echo -e "${YELLOW}Press Enter to continue...${NC}")" -n 1
            ;;
