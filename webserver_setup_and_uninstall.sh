1	#!/bin/bash
2	
3	# Clear the screen
4	clear
5	
6	# Display a large greeting message
7	echo "================================="
8	echo "Made by LucaDevelopment for you"
9	echo "================================="
10	echo "Automated Web Server Setup and Uninstall Script"
11	echo "This script will guide you through the setup or uninstallation process."
12	echo "================================="
13	
14	# Function to display a menu for setup or uninstallation
15	function display_menu() {
16	    echo "Please select an option:"
17	    echo "1. Set up the web server"
18	    echo "2. Uninstall the web server"
19	    echo "3. Exit"
20	    read -p "Enter your choice (1/2/3): " action_choice
21	
22	    case $action_choice in
23	        1)
24	            echo "Great! Let's set up your web server."
25	            read -p "What is your domain (Leave empty if not using a domain): " domain
26	            echo "You need to link an A record of your domain to your server's IP address."
27	            echo "Ensure that Nginx is properly configured and reachable on the domain."
28	            echo "Setting up the server with domain: $domain"
29	            setup_server
30	            ;;
31	        2)
32	            echo "You chose to uninstall the web server."
33	            uninstall_prompt
34	            ;;
35	        3)
36	            echo "Exiting..."
37	            exit 0
38	            ;;
39	        *)
40	            echo "Invalid choice. Please run the script again and select a valid option."
41	            exit 1
42	            ;;
43	    esac
44	}
45	
46	# Function to setup the web server
47	function setup_server() {
48	    echo "Updating system..."
49	    sudo apt update && sudo apt upgrade -y
50	
51	    echo "Installing Nginx, PHP, and other necessary packages..."
52	    sudo apt install -y nginx php-fpm php-mysql git
53	
54	    echo "Cloning the repository..."
55	    sudo git clone https://github.com/gglucabest/webshop-template.git /var/www/html/webshop
56	
57	    echo "Configuring Nginx..."
58	    if [ -z "$domain" ]; then
59	        server_name="localhost"
60	    else
61	        server_name="$domain"
62	    fi
63	
64	    sudo bash -c "cat > /etc/nginx/sites-available/webshop <<EOF
65	server {
66	    listen 80;
67	    server_name $server_name;
68	    root /var/www/html/webshop;
69	    index index.php index.html index.htm;
70	
71	    location / {
72	        try_files \$uri \$uri/ =404;
73	    }
74	
75	    location ~ \.php\$ {
76	        include snippets/fastcgi-php.conf;
77	        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
78	        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
79	        include fastcgi_params;
80	    }
81	}
82	EOF"
83	
84	    sudo ln -s /etc/nginx/sites-available/webshop /etc/nginx/sites-enabled/
85	    sudo nginx -t
86	    sudo systemctl restart nginx
87	
88	    echo "Setup complete! Your web server should be up and running."
89	    echo "Remember to verify your domain's DNS settings to ensure it points to your server's IP address."
90	}
91	
92	# Function to uninstall the web server
93	function uninstall_server() {
94	    echo "Uninstalling the web server..."
95	    sudo systemctl stop nginx
96	    sudo apt purge -y nginx php-fpm php-mysql
97	    sudo rm -rf /var/www/html/webshop
98	    sudo rm -f /etc/nginx/sites-available/webshop
99	    sudo rm -f /etc/nginx/sites-enabled/webshop
100	    sudo nginx -t
101	    sudo systemctl restart nginx
102	    echo "Uninstallation complete!"
103	}
104	
105	# Function to handle the uninstallation request
106	function uninstall_prompt() {
107	    echo "Are you sure you want to uninstall the web server? (yes/no)"
108	    read -p "Answer: " uninstall_choice
109	
110	    if [[ "$uninstall_choice" == "yes" ]]; then
111	        uninstall_server
112	    elif [[ "$uninstall_choice" == "no" ]]; then
113	        echo "Uninstallation aborted. Exiting..."
114	        exit 0
115	    else
116	        echo "Invalid choice. Exiting..."
117	        exit 1
118	    fi
119	}
120	
121	# Main script logic
122	display_menu
Copy
