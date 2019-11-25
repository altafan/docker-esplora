#!/bin/bash

set -e 

if [ ! -d /usr/share/nginx/html ]
then
    cd /esplora

    npm run dist
    mkdir -p /usr/share/nginx/html
    cp -a dist/. /usr/share/nginx/html

    echo "user  nginx;
    worker_processes  1;
    daemon off;

    error_log  /var/log/nginx/error.log warn;
    pid        /var/run/nginx.pid;


    events {
        worker_connections  1024;
    }


    http {
        include       /etc/nginx/mime.types;
        default_type  application/octet-stream;

        log_format  main  '$remote_addr - $remote_user [$time_local] \"$request\" '
                        '$status $body_bytes_sent \"$http_referer\" '
                        '\"$http_user_agent\" \"$http_x_forwarded_for\"';

        access_log  /var/log/nginx/access.log  main;

        sendfile        on;

        keepalive_timeout  65;

        include /etc/nginx/conf.d/default.conf;
    }" > /etc/nginx/nginx.conf

    echo "server {
        listen       "$PORT";
        server_name _;

        access_log  /var/log/nginx/host.access.log  main;

        location / {
            root   /usr/share/nginx/html;
            index  index.html index.htm;
        }

        location /api/ {
            proxy_set_header Access-Control-Allow-Origin *;
            proxy_pass "$API_URL";
        }

        error_page  404     /notfound.html;
        location /notfound.html {
            root   /usr/share/nginx/html;
        }

        error_page   500 502 503 504  /50x.html;
        location /50x.html {
            root   /usr/share/nginx/html;
        }
    }" > /etc/nginx/conf.d/default.conf
fi

cd /usr/share/nginx/html

echo "Serving on port $PORT..."
nginx