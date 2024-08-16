#!/bin/bash
# Script version: 1.0

# Prompt the user for the repository URL
read -p "Enter project folder's name: " REPO_NAME

# Prompt the user for the public IP address
read -p "Enter the server name (IP address or domain): " SERVER_NAME

# Set up service that can run our app with Uvicorn on the backgound.
cat <<EOL | sudo tee /etc/systemd/system/fastapi.service
[Unit]
Description=FastAPI app with Uvicorn
After=network.target

[Service]
User=ubuntu
Group=www-data
WorkingDirectory=/home/ubuntu/$REPO_NAME
ExecStart=/home/ubuntu/$REPO_NAME/.venv/bin/uvicorn main:app --host 0.0.0.0 --port 8000
Restart=always

[Install]
WantedBy=multi-user.target
EOL

sudo systemctl daemon-reload
sudo systemctl start fastapi.service
sudo systemctl enable fastapi.service

sudo apt install nginx -y

cat <<EOL | sudo tee /etc/nginx/sites-available/fastapi
server {
    listen 80;
    server_name $SERVER_NAME;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOL

sudo ln -s /etc/nginx/sites-available/fastapi /etc/nginx/sites-enabled
sudo nginx -t
sudo systemctl restart nginx

# Regular expression to check if input is an IP address
IP_REGEX="^([0-9]{1,3}\.){3}[0-9]{1,3}$"

# Check if the input matches the IP address pattern
if [[ $SERVER_NAME =~ $IP_REGEX ]]; then
    echo "You entered an IP address: $SERVER_NAME"

else
    echo "You entered a domain name: $SERVER_NAME"
    
    # Prompt the user to check if HTTPS is required
    read -p "Do you need to set up HTTPS? (y/n): " SET_HTTPS

    if [[ "$SET_HTTPS" == "y" || "$SET_HTTPS" == "Y" ]]; then
        echo "Setting up HTTPS..."
    
        sudo apt install certbot python3-certbot-nginx -y
        sudo certbot --nginx -d $SERVER_NAME
        echo "HTTPS has been set up successfully."  
    else
        echo "HTTPS setup skipped."
    fi
fi