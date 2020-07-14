FROM php:7.4.8-fpm
MAINTAINER Nicolas Canfrere

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update

ARG deps="git gnupg apt-utils apt-transport-https build-essential openssh-client rsync sqlite3 zip unzip vim"

RUN apt-get install -y --no-install-recommends $deps

RUN apt-get install -y --no-install-recommends \
	libgmp-dev \
	libfreetype6-dev \
	libjpeg-dev \
	libpng-dev \
	libc-client-dev \
	libkrb5-dev \
	libldb-dev \
	libldap2-dev \
	libbz2-dev \
	libxml2-dev \
	libenchant-dev \
	firebird-dev \
	freetds-dev \
	libpq-dev \
	libpspell-dev \
	librecode-dev \
	libtidy-dev \
	libxslt-dev \
	libmagickwand-dev \
	librabbitmq-dev \
	libzip-dev \
	libsqlite3-dev


RUN ln -s /usr/lib/x86_64-linux-gnu/libsybdb.a /usr/lib/libsybdb.a
RUN ln -s /usr/lib/x86_64-linux-gnu/libsybdb.so /usr/lib/libsybdb.so
RUN ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/local/include/
RUN ln -s /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/libldap.so
RUN ln -s /usr/lib/x86_64-linux-gnu/liblber.so /usr/lib/liblber.so

RUN docker-php-ext-configure zip

RUN docker-php-ext-configure gmp

RUN docker-php-ext-configure gd --with-freetype --with-jpeg

RUN docker-php-ext-configure imap --with-imap --with-kerberos --with-imap-ssl

ARG modules="bcmath bz2 calendar dba enchant exif gd gettext gmp imap intl ldap mysqli opcache pcntl pdo_dblib pdo_firebird pdo_mysql pdo_pgsql pdo_sqlite pgsql pspell shmop soap sockets sysvmsg sysvsem sysvshm tidy xmlrpc xsl zip"

RUN docker-php-ext-install $modules

# sodium n'est pas activé par défaut dans le core php
RUN docker-php-ext-enable sodium

RUN pecl install imagick-3.4.3 \
    && docker-php-ext-enable imagick
RUN pecl install apcu \
  && docker-php-ext-enable apcu
RUN pecl install redis \
	&& docker-php-ext-enable redis
RUN pecl install amqp \
	&& docker-php-ext-enable amqp
RUN pecl install xdebug \
	&& docker-php-ext-enable xdebug

RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"
# RUN sed -i 's|;sendmail_path =|sendmail_path = /usr/bin/mhsendmail --smtp-addr mailhog:1025|g' $PHP_INI_DIR/php.ini
COPY configs/xxxx-custom.ini $PHP_INI_DIR/conf.d/

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && ln -s $(composer config --global home) /root/composer
ENV PATH=$PATH:/root/composer/vendor/bin COMPOSER_ALLOW_SUPERUSER=1

RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
	&& echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get install -y nodejs yarn --no-install-recommends

#RUN curl -OL https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar
#RUN mv phpcs.phar /usr/local/bin/phpcs
#RUN chmod a+x /usr/local/bin/phpcs

#RUN curl -OL https://phar.phpunit.de/phploc.phar
#RUN chmod a+x phploc.phar
#RUN mv phploc.phar /usr/local/bin/phploc

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
