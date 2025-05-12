# Uses AlmaLinux 8 as base
FROM almalinux/8-minimal

# Installs nginx
RUN dnf install -y nginx && \
    dnf install wget unzip yum

# Set working directory
WORKDIR /usr/share/nginx/html

# Cleans existing content and download RoboShop UI
RUN rm -rf /usr/share/nginx/html/* && \
    wget https://buildbucket5.s3.us-east-1.amazonaws.com/RoboShop/web.zip && \
    unzip -o web.zip && \
    rm -f web.zip && \
    sed -i "s/splash.html/shell.html/g" /usr/share/nginx/html/js/controller.js

# Adds custom Nginx configuration
RUN echo 'proxy_http_version 1.1;
location /images/ {
expires 5s;
root   /usr/share/nginx/html;
try_files \$uri /images/placeholder.jpg;
}
location /api/catalogue/ { proxy_pass http://localhost:8082/; }
location /api/user/ { proxy_pass http://localhost:8081/; }
location /api/cart/ { proxy_pass http://localhost:8083/; }
location /api/shipping/ { proxy_pass http://localhost:8084/; }
location /api/payment/ { proxy_pass http://localhost:8085/; }
location /health {
stub_status on;
access_log off;
}' > /etc/nginx/default.d/roboshop.conf

# Exposes HTTP port
EXPOSE 80

# Starts nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
