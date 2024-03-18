FROM docker.io/php:8.3-apache
MAINTAINER Thomas Riechert <thomas.riechert@htwk-leipzig.de>



# upgrade
RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install wget unzip zip 

# Install GD
RUN apt-get install -y libfreetype6-dev libjpeg62-turbo-dev libpng-dev libonig-dev libzip-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd

# Install mysql
RUN docker-php-ext-install mysqli pdo pdo_mysql zip

RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini
RUN sed -i 's/128M/1024M/g' /usr/local/etc/php/php.ini

RUN apt-get clean

RUN a2enmod rewrite

WORKDIR /root

#Buildfile
COPY start.sh .

CMD ["bash", "start.sh"]
