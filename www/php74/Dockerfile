FROM php:7.4-apache

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV COMPOSER_ALLOW_SUPERUSER=1

# Install system dependencies and PHP extensions in a single layer
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        apt-utils \
        nano \
        wget \
        dialog \
        default-mysql-client \
        build-essential \
        git \
        curl \
        zip \
        unzip \
        openssl \
        iputils-ping \
        # Library dependencies
        libsqlite3-dev \
        libsqlite3-0 \
        zlib1g-dev \
        libzip-dev \
        libicu-dev \
        libonig-dev \
        libcurl4-openssl-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libmagickwand-dev \
    && rm -rf /var/lib/apt/lists/*

# Configure and install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-configure calendar && \
    docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        pdo_sqlite \
        mysqli \
        curl \
        tokenizer \
        json \
        zip \
        intl \
        mbstring \
        gettext \
        calendar \
        exif \
        gd \
        bcmath \
        opcache

# Install PECL extensions (versions compatible with PHP 7.4)
RUN pecl install \
        xdebug-3.1.6 \
        redis-5.3.7 \
        imagick \
    && docker-php-ext-enable \
        xdebug \
        redis \
        imagick

# Create xdebug log directory
RUN mkdir -p /var/log/xdebug

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

# Configure Apache modules
RUN a2enmod ssl rewrite headers

# Create SSL directory
RUN mkdir -p /etc/apache2/ssl

# Copy PHP configuration
COPY php.ini /usr/local/etc/php/conf.d/custom.ini

# Set working directory
WORKDIR /var/www/html

# Cleanup
RUN rm -rf /usr/src/* /tmp/* /var/tmp/*

# Reset environment
ENV DEBIAN_FRONTEND=dialog
