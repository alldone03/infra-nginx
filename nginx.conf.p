server {
    listen 80;
    server_name app.insamo.id apiapp.insamo.id;
    root /var/www/html;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}


server {
    listen 443;
    server_name app.insamo.id apiapp.insamo.id;
    root /var/www/html;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}