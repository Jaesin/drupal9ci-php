FROM php:8.1.11-fpm-alpine

## Add additional tools ##
RUN apk add --no-cache git patch su-exec rsync mariadb-client postgresql-client

## Add PHP Extensions ##
RUN apk add --no-cache zlib-dev libpng-dev libjpeg-turbo-dev freetype-dev libmcrypt-dev icu-dev libpq-dev
## Configure extensions.
RUN docker-php-ext-configure opcache --enable-opcache \
  && docker-php-ext-configure gd --with-freetype --with-jpeg
## Add PHP extensions.
RUN yes '' | pecl install mcrypt
RUN yes '' | pecl install redis
RUN yes '' | pecl install apcu
RUN yes '' | pecl install xdebug
RUN yes '' | pecl install ast
## Enable extensions.
RUN docker-php-ext-install -j$(nproc) gd intl opcache pdo pdo_mysql pdo_pgsql \
  && docker-php-ext-enable mcrypt redis apcu xdebug ast \
  && mkdir -p $PHP_INI_DIR/mods-available/ \
  && mv $PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini $PHP_INI_DIR/mods-available/ \
  && ln -s ../mods-available/docker-php-ext-xdebug.ini $PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini \
  && rm -r /usr/src/* /tmp/*

## Configure PHP ##
RUN ln -s php.ini-development $PHP_INI_DIR/php.ini

## Add Composer ##
COPY --from=composer:2.4.3 /usr/bin/composer /usr/bin/composer

## Add phpstan ##
RUN wget -O /usr/local/bin/phpstan https://github.com/phpstan/phpstan/releases/download/1.8.10/phpstan.phar \
    && chmod 755 /usr/local/bin/phpstan \
    && echo "34c65d4aa823b53b7d500ddeca7704f4da3672e8  /usr/local/bin/phpstan" | sha1sum -c - \
    && phpstan --version

## Add Psalm ##
COPY --from=jaesin/psalm-builder:4.29.0 /usr/local/bin/psalm /usr/local/bin/psalm

## Add PHPCS ##
RUN wget -O /usr/local/bin/phpcs https://github.com/squizlabs/PHP_CodeSniffer/releases/download/3.7.1/phpcs.phar \
    && chmod 755 /usr/local/bin/phpcs \
    && phpcs --version \
    && echo "7323dd2945e661807b283a7468d6826418c72dd7  /usr/local/bin/phpcs" | sha1sum -c -

RUN composer global config --no-plugins allow-plugins.dealerdirect/phpcodesniffer-composer-installer true \
  && composer global require drupal/coder \
  && /usr/local/bin/phpcs --config-set installed_paths /root/.composer/vendor/drupal/coder/coder_sniffer
