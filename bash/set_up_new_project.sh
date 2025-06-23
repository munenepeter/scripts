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
PHP_VERSION="$2"

if [ -z "$PROJECT" ] || [ -z "$PHP_VERSION" ]; then
  echo "Usage: $0 projectname php_version"
  echo "Example: $0 suitecrm7 8.3"
  exit 1
fi

DOMAIN="${PROJECT}.local"
DOCROOT="/var/www/$PROJECT"
VHOST_CONF="/etc/apache2/sites-available/${DOMAIN}.conf"
PHP_FPM_SOCK="/run/php/php${PHP_VERSION}-fpm.sock"

# Check and install PHP version if needed
if ! php -v | grep -q "$PHP_VERSION"; then
  echo "[i] PHP $PHP_VERSION not found. Installing..."
  sudo apt update
  sudo apt install -y php$PHP_VERSION php$PHP_VERSION-fpm
  sudo apt install --no-install-recommends php$PHP_VERSION-cli php$PHP_VERSION-common php$PHP_VERSION-mbstring php$PHP_VERSION-xml php$PHP_VERSION-curl php$PHP_VERSION-mysql php$PHP_VERSION-zip php$PHP_VERSION-gd php$PHP_VERSION-bcmath php$PHP_VERSION-intl php$PHP_VERSION-json php$PHP_VERSION-opcache
  sudo systemctl restart php${PHP_VERSION}-fpm
  sudo systemctl enable php${PHP_VERSION}-fpm
  echo "[+] Installed PHP $PHP_VERSION and FPM"
else
  echo "[✓] PHP $PHP_VERSION is already installed"
fi

# Enable required Apache modules
sudo a2enmod proxy_fcgi setenvif
sudo a2enconf php${PHP_VERSION}-fpm
sudo systemctl reload apache2

# /etc/hosts
if ! grep -q "$DOMAIN" /etc/hosts; then
  echo "127.0.0.1  $DOMAIN" | sudo tee -a /etc/hosts > /dev/null
fi

# Create project dir
if [ ! -d "$DOCROOT" ]; then
  sudo mkdir -p "$DOCROOT"
  sudo chown -R "$USER":www-data "$DOCROOT"
fi

# Apache vhost config with PHP-FPM
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

    <FilesMatch \.php$>
        SetHandler "proxy:unix:$PHP_FPM_SOCK|fcgi://localhost/"
    </FilesMatch>

    ErrorLog \${APACHE_LOG_DIR}/${PROJECT}_error.log
    CustomLog \${APACHE_LOG_DIR}/${PROJECT}_access.log combined
</VirtualHost>
EOF
  echo "[+] Created vhost for $DOMAIN with PHP $PHP_VERSION"
fi

# Enable site & reload Apache
sudo a2ensite "${DOMAIN}.conf"
sudo systemctl reload apache2

echo "[✓] $DOMAIN set up with PHP $PHP_VERSION → http://$DOMAIN"
