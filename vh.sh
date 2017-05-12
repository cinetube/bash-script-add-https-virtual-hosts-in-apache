printf 'Enter a domain name: \n'
read domain

openssl req -new -x509 -days 360 -keyout "$domain".key -out "$domain".pem

cp "$domain".key
openssl rsa -in "$domain".key -out "$domain".key

sudo cp "$domain".pem /etc/ssl/certs/
sudo cp "$domain".key /etc/ssl/private/
sudo chmod 0600 /etc/ssl/private/"$domain".key

rm "$domain".key
rm "$domain".pem

sudo mkdir -p /var/www/"$domain"/
sudo chown -R igor /var/www/"$domain"/

sudo touch /etc/apache2/sites-available/"$domain".conf

sudo sh -c "echo '
<VirtualHost *:80>
ServerAdmin webmaster@localhost
ServerName $domain
DocumentRoot /var/www/$domain/
</VirtualHost>
<IfModule mod_ssl.c>
<VirtualHost *:443>
ServerAdmin webmaster@localhost
ServerName $domain
DocumentRoot /var/www/$domain/
SSLEngine on
SSLCertificateFile /etc/ssl/certs/$domain.pem
SSLCertificateKeyFile /etc/ssl/private/$domain.key
</VirtualHost>
</IfModule>
<Directory /var/www/$domain/>
Options Indexes FollowSymLinks MultiViews
AllowOverride All
Order allow,deny
allow from all
</Directory>
 ' >> /etc/apache2/sites-available/$domain.conf"

sudo a2ensite "$domain".conf

sudo service apache2 restart

sudo sh -c "echo '127.0.0.1 $domain' >> /etc/hosts"