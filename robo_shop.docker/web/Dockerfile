# Uses AlmaLinux 8 as base
FROM almalinux:8

# Installs nginx
RUN dnf install -y nginx && \
  dnf install -y wget unzip

# Set working directory
WORKDIR /usr/share/nginx/html

# Cleans existing content and download RoboShop UI
RUN rm -rf /usr/share/nginx/html/* && \
  wget https://buildbucket5.s3.us-east-1.amazonaws.com/RoboShop/web.zip && \
  unzip -o web.zip && \
  rm -f web.zip && \
  sed -i "s/splash.html/shell.html/g" /usr/share/nginx/html/js/controller.js

# Adds custom Nginx configuration
RUN mkdir -p /etc/nginx/default.d/

COPY roboshop.conf /etc/nginx/default.d/roboshop.conf

# Exposes HTTP port
EXPOSE 80

# Starts nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
