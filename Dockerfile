FROM python:3.11-slim AS base

#Install system packages (php, nginx, etc.)

RUN apt-get update && apt-get install -y \
    python3-dev gcc libpq-dev \
    php php-fpm php-mysqli php-pgsql php-sqlite3 curl unzip nginx supervisor && \
    rm -rf /var/lib/apt/lists/*
#Install Adminer

# Download Adminer into /var/www/html
RUN mkdir -p /var/www/html && \
    curl -L -o /var/www/html/index.php https://www.adminer.org/latest.php
#Setup Django

WORKDIR /app COPY requirements.txt . RUN pip install --no-cache-dir -r requirements.txt COPY . .

# Nginx + PHP config
COPY deploy/nginx.conf /etc/nginx/sites-enabled/default
COPY deploy/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
#Collect static files

RUN python manage.py collectstatic --noinput

EXPOSE 8000

CMD ["/usr/bin/supervisord"]
