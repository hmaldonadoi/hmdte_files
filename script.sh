#!/bin/bash
apt install software-properties-common
add-apt-repository ppa:ondrej/php
apt update 
apt-get install php7.3 php7.3-cli php7.3-common curl git mercurial apache2 php7.3-gd php7.3-imap php7.3-curl php7.3-soap php7.3-mbstring php7.3-xml npm postgresql php7.3-pgsql php7.3-intl unzip ifstat php7.3-zip  php-pear -y
sleep 2s
npm install xoauth2
pear install Mail Mail_mime Net_SMTP
sleep 2s
echo -e "\n----Vamos a instalar sowerpkg ----"
wget -c https://github.com/SowerPHP/sowerpkg/raw/master/sowerpkg.sh
chmod +x sowerpkg.sh
./sowerpkg.sh install -e "app general" -W
sleep 2s

echo -e "\n----Vamos a instalar Composer ----"
sleep 2s
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
HASH="$(wget -q -O - https://composer.github.io/installer.sig)"
php -r "if (hash_file('SHA384', 'composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
sleep 6s
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer

echo -e "\n----Vamos a Clonar Repo LibreDTE ----"
sleep 2s
cd /var/www/html/
git clone --recursive https://github.com/LibreDTE/libredte-webapp.git hmdte
cd hmdte/website/
composer install
sleep 3s
clear

wget https://raw.githubusercontent.com/hmaldonadoi/hmdte_files/master/core.php
mv core.php /var/www/html/hmdte/website/Config/core.php
cp /var/www/html/hmdte/website/Config/routes-dist.php /var/www/html/hmdte/website/Config/routes.php
mkdir /var/www/html/hmdte/data/static
mkdir /var/www/html/hmdte/data/static/contribuyentes

wget https://hmmarket.cl/hmdte/img/logo.png
mv logo.png /var/www/html/hmdte/website/webroot/img/logo.png

wget https://raw.githubusercontent.com/hmaldonadoi/hmdte_files/master/inicio.md
mv inicio.md mv logo.png /var/www/html/hmdte/website/View/Pages/inicio.md

wget https://raw.githubusercontent.com/hmaldonadoi/hmdte_files/master/EnvioBoleta.php
mv EnvioBoleta.php mv logo.png /var/www/html/hmdte/website/Module/Dte/Utility/EnvioBoleta.php



chgrp www-data /var/www/html/hmdte/data/static/contribuyentes/
usermod -a -G www-data www-data
chmod -R 775 /var/www/html/hmdte/data/static/contribuyentes/
chown -R www-data:www-data /var/www/html/*

a2enmod rewrite

systemctl restart apache2
clear
cd /tmp/
wget https://raw.githubusercontent.com/tdcomcl/Libredte_/master/Ods/datos.csv
wget https://raw.githubusercontent.com/tdcomcl/Libredte_/master/Ods/division_geopolitica.csv
wget https://raw.githubusercontent.com/tdcomcl/Libredte_/master/Ods/actividad_economica.csv
wget https://raw.githubusercontent.com/tdcomcl/Libredte_/master/Ods/provincia.csv
wget https://raw.githubusercontent.com/tdcomcl/Libredte_/master/Ods/iva_no_recuperable.csv
wget https://raw.githubusercontent.com/tdcomcl/Libredte_/master/Ods/impuesto_adicional.csv
wget https://raw.githubusercontent.com/tdcomcl/Libredte_/master/Ods/dte_tipo.csv
wget https://raw.githubusercontent.com/tdcomcl/Libredte_/master/Ods/comuna.csv

wget https://raw.githubusercontent.com/hmaldonadoi/hmdte_files/master/.pgpass
mv .pgpass /root/.pgpass
chmod 0600 /root/.pgpass

sudo service postgresql restart

cd /root/

su - postgres -c "createdb libredte"  #crea base de datos 
sudo -u postgres psql -c  "create user hmdte with encrypted password '*8686&1205*';"

psql -U hmdte -h localhost hmdte < /usr/share/sowerphp/extensions/sowerphp/app/Module/Sistema/Module/Usuarios/Model/Sql/PostgreSQL/usuarios.sql
psql -U hmdte -h localhost hmdte < /usr/share/sowerphp/extensions/sowerphp/app/Module/Sistema/Module/General/Model/Sql/moneda.sql
psql -U hmdte -h localhost hmdte < /var/www/html/hmdte/website/Module/Sistema/Module/General/Model/Sql/PostgreSQL/actividad_economica.sql
psql -U hmdte -h localhost hmdte < /usr/share/sowerphp/extensions/sowerphp/app/Module/Sistema/Module/General/Module/DivisionGeopolitica/Model/Sql/PostgreSQL/division_geopolitica.sql
psql -U hmdte -h localhost hmdte < /var/www/html/hmdte/website/Module/Dte/Model/Sql/PostgreSQL.sql
sleep 30s

echo -e "hasta solo falta cargar csv"

psql -U hmdte -h localhost hmdte -c "\COPY actividad_economica FROM '/tmp/actividad_economica.csv' delimiter ',' csv header;"
########
sleep 30s
psql -U hmdte -h localhost hmdte -c "\COPY dte_referencia_tipo FROM '/tmp/datos.csv' delimiter ',' csv header;"
psql -U hmdte -h localhost hmdte -c "\COPY dte_tipo FROM '/tmp/dte_tipo.csv' delimiter ',' csv header;"
psql -U hmdte -h localhost hmdte -c "\COPY impuesto_adicional FROM '/tmp/impuesto_adicional.csv' delimiter ',' csv header;"
psql -U hmdte -h localhost hmdte -c "\COPY iva_no_recuperable FROM '/tmp/iva_no_recuperable.csv' delimiter ',' csv header;"

########
sleep 30s
psql -U hmdte -h localhost hmdte -c "\COPY region FROM '/tmp/division_geopolitica.csv' delimiter ',' csv header;"
psql -U hmdte -h localhost hmdte -c "\COPY provincia FROM '/tmp/provincia.csv' delimiter ',' csv header;"
psql -U hmdte -h localhost hmdte -c "\COPY comuna FROM '/tmp/comuna.csv' delimiter ',' csv header;"

########
sleep 30s
psql -U hmdte -h localhost hmdte -c "INSERT INTO contribuyente VALUES (55555555, '5', 'Extranjero', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NOW());"
psql -U hmdte -h localhost hmdte -c "INSERT INTO contribuyente VALUES (66666666, '6', 'Sin razón social informada', 'Sin giro informado', NULL, NULL, NULL, 'Sin dirección informada', '13101', NULL, NOW());"

sleep 5s
wget https://raw.githubusercontent.com/hmaldonadoi/hmdte_files/master/script_pgsql.sh
wget https://raw.githubusercontent.com/hmaldonadoi/hmdte_files/master/Psql_.sh
./script_psql.sh
rm script_psql.sh
rm Psql_.sh


echo -e "\n----Ingresar por web http://dominio.cl ----"
echo -e "\n----Listo solo falta poblar datos! ----"
