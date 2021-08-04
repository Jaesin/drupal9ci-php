# [jaesin/drupal9ci-php](https://hub.docker.com/repository/docker/jaesin/drupal9ci-php)

This Docker project adds the minimum Drupal 9 requirements to the official [php:8.x-fpm-alpine](https://hub.docker.com/_/php) image. It can be used as a php-fpm image for automated tests for Drupal 9.

Development by Jaesin Mulenex at <https://github.com/jaesin/drupal9ci-php>.

## Composer

In order to install dependencies you can use `/usr/local/bin/composer -d /var/www/html install`. It may be the case you only need to install dev dependencies but the command is the same.
