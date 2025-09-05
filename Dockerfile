FROM python:3.11-slim AS base

#Install system packages (php, nginx, etc.)

RUN apt-get update && apt-get install -y \
    python3-dev gcc libpq-dev \
    php php-fpm php-mysql php-pgsql php-sqlite3 \
    curl unzip nginx supervisor && \
    rm -rf /var/lib/apt/lists/*
#Install Adminer
RUN ln -s /usr/sbin/php-fpm8.4 /usr/sbin/php-fpm
# Download Adminer into /var/www/html
RUN mkdir -p /var/www/html && \
    curl -L -o /var/www/html/index.php https://www.adminer.org/latest.php
#Setup Django
# Install Adminer
RUN mkdir -p /var/www/html \
    && curl -L https://www.adminer.org/latest.php -o /var/www/html/adminer.php

# Set working directory
WORKDIR /app

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY . .

# Nginx + PHP config
COPY deploy/nginx.conf /etc/nginx/sites-enabled/default
COPY deploy/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

#Collect static files
RUN python manage.py migrate --noinput
RUN python manage.py collectstatic --noinput

EXPOSE 8000

CMD ["/usr/bin/supervisord"]
