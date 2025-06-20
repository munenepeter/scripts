#!/bin/bash

# Simple script made with the help of ChatGPT to create a local site on Apache.
# It adds the domain to /etc/hosts, creates a project directory, sets up an
# Apache virtual host configuration, and enables the site.

# Please avoid funny characters in the project name.

# THE SCRIPT ASSUMES:
# - You have Apache installed and running.
# - You have sudo privileges to modify /etc/hosts and Apache configurations.

# Usage: ./new-project.sh projectname

PROJECT="$1"

# Check if project name is provided and does not contain funny characters
# no spaces, no special characters
if [[ ! "$PROJECT" =~ ^[a-zA-Z0-9_-]+$ ]]; then
  echo "Error: Project name can only contain alphanumeric characters, underscores, and hyphens."
  exit 1

if [ -z "$PROJECT" ]; then
  echo "Usage: $0 projectname"
  exit 1
fi

DOMAIN="${PROJECT}.local"
DOCROOT="/var/www/$PROJECT"
VHOST_CONF="/etc/apache2/sites-available/${DOMAIN}.conf"

# 1. Add to /etc/hosts
if ! grep -q "$DOMAIN" /etc/hosts; then
  echo "127.0.0.1  $DOMAIN" | sudo tee -a /etc/hosts > /dev/null
  echo "[+] Added $DOMAIN to /etc/hosts"
else
  echo "[i] $DOMAIN already exists in /etc/hosts"
fi

# 2. Create project directory
if [ ! -d "$DOCROOT" ]; then
  sudo mkdir -p "$DOCROOT"
  sudo chown -R "$USER":www-data "$DOCROOT"
  echo "[+] Created $DOCROOT"
else
  echo "[i] $DOCROOT already exists"
fi

# 3. Create Apache vhost config
if [ ! -f "$VHOST_CONF" ]; then
  sudo tee "$VHOST_CONF" > /dev/null <<EOF
<VirtualHost *:80>
    ServerName $DOMAIN
    DocumentRoot $DOCROOT

    <Directory $DOCROOT>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/${PROJECT}_error.log
    CustomLog \${APACHE_LOG_DIR}/${PROJECT}_access.log combined
</VirtualHost>
EOF

  echo "[+] Created vhost config: $VHOST_CONF"
else
  echo "[i] Vhost config $VHOST_CONF already exists"
fi

# 4. Enable the site and reload Apache
sudo a2ensite "${DOMAIN}.conf"
sudo systemctl reload apache2
echo "[✓] Site $DOMAIN is now active at http://$DOMAIN"
