server {
listen 80 default_server;
listen [::]:80 default_server;
root /var/www/html;
add_header X-Frame-Options "SAMEORIGIN";
add_header X-XSS-Protection "1; mode=block";
add_header X-Content-Type-Options "nosniff";
client_body_timeout 10s;
client_header_timeout 10s;
client_max_body_size 256M;
index index.html index.php;
charset utf-8;
server_tokens off;
location / {
try_files \$uri \$uri/ /index.php?\$query_string;
}
location = /favicon.ico { access_log off; log_not_found off; }
location = /robots.txt { access_log off; log_not_found off; }
error_page 404 /index.php;
location ~ \.php$ {
include snippets/fastcgi-php.conf;
fastcgi_pass unix:/var/run/php/php8.0-fpm.sock;
}
location ~ /\.(?!well-known).* {
deny all;
}
}