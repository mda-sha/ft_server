FROM debian:buster

ENV AUTOINDEX on

RUN apt-get update
RUN apt-get -y install nginx
RUN apt-get -y install mariadb-server
RUN apt-get -y install wget
RUN apt-get -y install php7.3 php-mysql php-fpm php-pdo php-gd php-cli php-mbstring

COPY ./srcs/init.sh ./
COPY ./srcs/nginx.conf /etc/nginx/sites-available/localhost
RUN ln -s /etc/nginx/sites-available/localhost /etc/nginx/sites-enabled/localhost
RUN rm /etc/nginx/sites-enabled/default


WORKDIR /var/www/html/

RUN wget https://files.phpmyadmin.net/phpMyAdmin/5.0.1/phpMyAdmin-5.0.1-english.tar.gz
RUN tar -xf phpMyAdmin-5.0.1-english.tar.gz && rm -rf phpMyAdmin-5.0.1-english.tar.gz
RUN mv phpMyAdmin-5.0.1-english ./phpmyadmin

COPY ./srcs/config.inc.php ./phpmyadmin/config.inc.php

RUN wget https://wordpress.org/latest.tar.gz
RUN tar -xvzf latest.tar.gz && rm -rf latest.tar.gz

COPY ./srcs/wp-config.php ./wordpress
COPY ./srcs/phpmyadmin.inc.php ./phpmyadmin

RUN rm index.nginx-debian.html

RUN openssl req -x509 -nodes -days 365 -subj "/C=ry/ST=khimki/L=khimki/O=fidel/OU=fidel/CN=localhost" -newkey rsa:2048 -keyout /etc/ssl/nginx-selfsigned.key -out /etc/ssl/nginx-selfsigned.crt;

RUN sed -i "s/autoindex on/autoindex $AUTOINDEX/g" ./../../../etc/nginx/sites-available/localhost

RUN chown -R www-data:www-data *
RUN chmod -R 755 /var/www/*

CMD bash ./../../../init.sh

EXPOSE 80 443



