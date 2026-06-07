#!/bin/sh
set -e

echo "Injecting runtime environment variables..."

find /usr/share/nginx/html -type f \( -name "*.js" -o -name "*.html" \) | while read file; do
  sed -i \
    -e "s|__NN_API_HOST__|${NN_API_HOST}|g" \
    -e "s|__NN_AUTH_HOST__|${NN_AUTH_HOST}|g" \
    -e "s|__NN_SSE_HOST__|${NN_SSE_HOST}|g" \
    -e "s|__NN_MONOGRAPH_HOST__|${NN_MONOGRAPH_HOST}|g" \
    "$file"
done

echo "Done. Starting nginx..."

exec nginx -g "daemon off;"
