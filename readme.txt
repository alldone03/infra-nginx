docker run --rm -it \
  -v $(pwd)/certs:/etc/letsencrypt \
  -v $(pwd)/certbot/www:/var/www/certbot \
  certbot/certbot certonly \
  --webroot -w /var/www/certbot \
  -d app.insamo.id -d apiapp.insamo.id -d cogniva.insamo.id \
  --email your-email@example.com \
  --agree-tos --non-interactive



curl -I https://app.insamo.id
curl -I https://apiapp.insamo.id
curl -I https://cogniva.insamo.id
curl -I https://IP_ADDRESS  # harus tampil "NGINX GATEWAY OK"