FROM php:8.4-apache

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
        nodejs \
        npm \
        chromium \
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
        libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# PostgreSQL client (pg_dump/psql) from the official PGDG repo, pinned to the
# postgres16 service major: pg_dump must be the same major as the server or newer.
ARG POSTGRES_CLIENT_VERSION=16
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates gnupg \
    && install -d /usr/share/postgresql-common/pgdg \
    && curl -fsSL -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc https://www.postgresql.org/media/keys/ACCC4CF8.asc \
    && . /etc/os-release \
    && echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt ${VERSION_CODENAME}-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
    && apt-get update && apt-get install -y --no-install-recommends postgresql-client-${POSTGRES_CLIENT_VERSION} \
    && apt-get purge -y gnupg \
    && rm -rf /var/lib/apt/lists/*

# Configure and install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-configure calendar && \
    docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        pdo_pgsql \
        pgsql \
        pdo_sqlite \
        mysqli \
        zip \
        intl \
        mbstring \
        gettext \
        calendar \
        exif \
        gd \
        bcmath \
        opcache

# Install PECL extensions
RUN pecl install \
        xdebug \
        redis \
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
