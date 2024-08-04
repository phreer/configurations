#!/bin/bash
if [ "$SITE_ADDRESS" = "" ]; then
  echo "Please set \$SITE_ADDRESS before running this script." 2>/dev/null
  exit 1
fi

docker run -it -p 8080:8080 \
  -v /home/phree/workspace/caddy-fs/Caddyfile:/etc/caddy/Caddyfile \
  -v /home/phree/workspace/caddy-fs/share:/share \
  -e SITE_ADDRESS="$SITE_ADDRESS" \
  --name caddy-fs caddy
