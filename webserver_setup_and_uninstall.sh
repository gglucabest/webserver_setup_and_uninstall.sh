#!/bin/bash

# Clear the screen
clear

# Display a large greeting message
echo "================================="
echo "Made by LucaDevelopment for you"
echo "================================="
echo "Automated Web Server Setup and Uninstall Script"
echo "This script will guide you through the setup or uninstallation process."
echo "================================="

# Function to display a menu for setup or uninstallation
function display_menu() {
    echo "Do you want to set up the web server? (yes/no)"
    read -p "Answer: " setup_choice

    if [[ "$setup_choice" == "yes" ]]; then
        echo "Great! Let's set up your web server."
        read -p "What is your domain (Leave empty if not using a domain): " domain
        echo "You need to link an A record of your domain to your server's IP address."
        echo "Ensure that Nginx is properly configured and reachable on the domain."
        echo "Setting up the server with domain: $domain"

        setup_server
    elif [[ "$setup_choice" == "no" ]]; then
        echo "You chose not to set up the server. Exiting..."
        exit 0
    else
        echo "Invalid choice. Exiting..."
        exit 1
    fi
}

# Function to setup the web server
function setup_server() {
    echo "Updating system..."
    sudo apt update && sudo apt upgrade -y

    echo "Installing Nginx and PHP..."
    sudo apt install -y nginx php-fpm php-mysql git

    echo "Cloning the repository..."
    sudo git clone https://github.com/gglucabest/webshop-template.git /var/www/html/webshop

    echo "Configuring Nginx..."
    if [ -z "$domain" ]; then
        server_name="localhost"
    else
        server_name="$domain"
    fi

    sudo bash -c "cat > /etc/nginx/sites-available/webshop <<EOF
server {
    listen 80;
    server_name $server_name;
    root /var/www/html/webshop;
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }
}
EOF"

    sudo ln -s /etc/nginx/sites-available/webshop /etc/nginx/sites-enabled/
    sudo nginx -t
    sudo systemctl restart nginx

    echo "Setup complete! Your web server should be up and running."
    echo "Remember to verify your domain's DNS settings to ensure it points to your server's IP address."
}

# Function to uninstall the web server
function uninstall_server() {
    echo "Uninstalling the web server..."
    sudo systemctl stop nginx
    sudo apt purge -y nginx php-fpm php-mysql
    sudo rm -rf /var/www/html/webshop
    sudo rm -f /etc/nginx/sites-available/webshop
    sudo rm -f /etc/nginx/sites-enabled/webshop
    sudo nginx -t
    sudo systemctl restart nginx
    echo "Uninstallation complete!"
}

# Function to handle the uninstallation request
function uninstall_prompt() {
    echo "Do you want to uninstall the web server? (yes/no)"
    read -p "Answer: " uninstall_choice

    if [[ "$uninstall_choice" == "yes" ]]; then
        uninstall_server
    elif [[ "$uninstall_choice" == "no" ]]; then
        echo "Uninstallation aborted. Exiting..."
        exit 0
    else
        echo "Invalid choice. Exiting..."
        exit 1
    fi
}

# Main script logic
echo "Do you want to set up or uninstall the web server? (setup/uninstall)"
read -p "Answer: " action_choice

if [[ "$action_choice" == "setup" ]]; then
    display_menu
elif [[ "$action_choice" == "uninstall" ]]; then
    uninstall_prompt
else
    echo "Invalid choice. Exiting..."
    exit 1
fi
