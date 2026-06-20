#!/bin/bash
set -euxo pipefail

dnf update -y
dnf install -y httpd php php-fpm php-mysqlnd php-json php-gd php-mbstring mariadb105-server wget unzip

systemctl enable httpd
systemctl enable php-fpm
systemctl enable mariadb
systemctl start mariadb
systemctl start php-fpm

mysql -u root <<SQL
CREATE DATABASE IF NOT EXISTS ${db_name};
CREATE USER IF NOT EXISTS '${db_user}'@'localhost' IDENTIFIED BY '${db_password}';
GRANT ALL PRIVILEGES ON ${db_name}.* TO '${db_user}'@'localhost';
FLUSH PRIVILEGES;
SQL

cd /tmp
wget -q https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
rsync -a wordpress/ /var/www/html/
chown -R apache:apache /var/www/html

curl -sO https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

cd /var/www/html
sudo -u apache wp config create \
  --dbname="${db_name}" \
  --dbuser="${db_user}" \
  --dbpass="${db_password}" \
  --dbhost="localhost" \
  --path="/var/www/html" \
  --skip-check

sudo -u apache wp core install \
  --url="http://$${PUBLIC_IP}" \
  --title="${name_prefix} WordPress" \
  --admin_user="admin" \
  --admin_password="ChangeMeAdmin123!" \
  --admin_email="admin@example.com" \
  --path="/var/www/html" \
  --skip-email

sudo -u apache wp plugin install amazon-s3-and-cloudfront --activate --path="/var/www/html"

# NOTE: do NOT use --raw here. The JSON value must be inserted as a PHP string
# (the plugin calls json_decode() on it at runtime). Using --raw inserts the
# JSON object as literal PHP code, which breaks wp-config.php syntax.
sudo -u apache wp config set AS3CF_SETTINGS \
  '{"provider":"aws","access-key-id":"","secret-access-key":"","use-server-roles":true,"bucket":"${bucket_name}","region":"${aws_region}","copy-to-s3":true,"serve-from-s3":true}' \
  --type=constant --path="/var/www/html"

chown -R apache:apache /var/www/html
systemctl restart httpd
systemctl restart php-fpm

echo "WordPress provisioning complete. Instance: $${INSTANCE_ID}"
