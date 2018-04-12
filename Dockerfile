FROM php:7-fpm-alpine

# intl, zip, soap
RUN apk add --update --no-cache libintl icu icu-dev libxml2-dev \
    && docker-php-ext-install intl zip soap

# mysqli, pdo, pdo_mysql
RUN docker-php-ext-install mysqli pdo pdo_mysql

# mcrypt
RUN apk add --update --no-cache libmcrypt-dev \
	&& apk add --no-cache --virtual .phpize-deps-configure $PHPIZE_DEPS \
	&& pecl install mcrypt-1.0.1 \
	&& docker-php-ext-enable mcrypt \
    && apk del .phpize-deps-configure \
    && docker-php-source delete

# mcrypt, gd, iconv
RUN apk add --update --no-cache freetype-dev libjpeg-turbo-dev libpng-dev \
    && docker-php-ext-install iconv \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd

# gmp, bcmath
# RUN apk add --update --no-cache gmp gmp-dev \
#     && docker-php-ext-install gmp bcmath

# redis, apcu
RUN docker-php-source extract \
    && apk add --no-cache --virtual .phpize-deps-configure $PHPIZE_DEPS \
    && pecl install redis \
    && pecl install apcu \
    && docker-php-ext-enable redis apcu \
    && apk del .phpize-deps-configure \
    && docker-php-source delete

# git client, mysql-client
RUN apk add --update --no-cache git mysql-client curl\
	&& curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR /usr/share/nginx/html

EXPOSE 9000
CMD ["php-fpm"]