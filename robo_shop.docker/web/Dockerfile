# Uses Alpine as base OS
FROM aline

# Installs nginx
RUN apk update && \
  apk add -y nginx && \
  apk add -y wget unzip yum

# Set working directory
WORKDIR /usr/share/nginx/html

# Cleans existing content and download RoboShop UI
RUN rm -rf /usr/share/nginx/html/* && \
  wget https://buildbucket5.s3.us-east-1.amazonaws.com/RoboShop/web.zip && \
  unzip -o web.zip && \
  rm -f web.zip && \
  sed -i "s/splash.html/docker.html/g" /usr/share/nginx/html/js/controller.js

# Adds custom Nginx configuration
RUN cat <<EOF > /etc/nginx/default.d/roboshop.conf
proxy_http_version 1.1;

location /images/ {
  expires 5s;
  root   /usr/share/nginx/html;
  try_files \$uri /images/placeholder.jpg;
}

location /api/catalogue/ { proxy_pass http://catalogue:8080/; }
location /api/user/ { proxy_pass http://user:8080/; }
location /api/cart/ { proxy_pass http://cart:8080/; }
location /api/shipping/ { proxy_pass http://shipping:8080/; }
location /api/payment/ { proxy_pass http://payment:8080/; }

location /health {
  stub_status on;
  access_log off;
}
EOF


# Exposes HTTP port
EXPOSE 80

# Starts nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
