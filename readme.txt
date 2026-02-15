docker compose up -d nginx
docker compose run --rm certbot certonly \
  --webroot \
  --webroot-path=/var/www/certbot \
  --email you@email.com \
  --agree-tos \
  --no-eff-email \
  -d cogniva.insamo.id \
  -d apicogniva.insamo.id \
  -d app.insamo.id \
  -d apiapp.insamo.id

  docker compose restart nginx


  docker exec nginx nginx -t
docker logs certbot
curl -I https://yourdomain.com