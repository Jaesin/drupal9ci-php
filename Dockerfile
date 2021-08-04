FROM php:8.0.9-fpm-alpine

## Add PHP Extensions ##
RUN apk add --no-cache zlib-dev libpng-dev libjpeg-turbo-dev freetype-dev libmcrypt-dev icu-dev \
  && docker-php-ext-configure opcache --enable-opcache \
  && docker-php-ext-configure gd --with-freetype --with-jpeg \
  && yes '' | pecl install mcrypt redis apcu xdebug \
  && docker-php-ext-install -j$(nproc) gd intl opcache pdo pdo_mysql \
  && docker-php-ext-enable mcrypt redis apcu xdebug \
  && mkdir -p $PHP_INI_DIR/mods-available/ \
  && mv $PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini $PHP_INI_DIR/mods-available/ \
  && ln -s ../mods-available/docker-php-ext-xdebug.ini $PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini \
  && rm -r /usr/src/* /tmp/*

## Configure PHP ##
RUN ln -s php.ini-development $PHP_INI_DIR/php.ini

## Add Composer ##
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer