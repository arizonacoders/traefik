#!/bin/sh

# Base command array
TRAEFIK_CMD="--log.level=DEBUG
             --providers.docker=true
             --api.dashboard=true
             --entrypoints.web.address=:80
             --entrypoints.websecure.address=:443
             --entrypoints.web.http.redirections.entryPoint.to=websecure
             --entrypoints.web.http.redirections.entryPoint.scheme=https
             --certificatesresolvers.le.acme.dnschallenge=true
             --certificatesresolvers.le.acme.dnschallenge.provider=cloudflare
             --certificatesresolvers.le.acme.email=${LE_EMAIL}
             --certificatesresolvers.le.acme.storage=/letsencrypt/acme.json
             --certificatesresolvers.le.acme.dnschallenge.resolvers=1.1.1.1:53,8.8.8.8:53
             --entrypoints.websecure.http.tls=true
             --entrypoints.websecure.http.tls.certResolver=le
             --entrypoints.web.forwardedHeaders.trustedIPs=173.245.48.0/20,103.21.244.0/22,103.22.200.0/22,103.31.4.0/22,141.101.64.0/18,108.162.192.0/18,190.93.240.0/20,188.114.96.0/20,197.234.240.0/22,198.41.128.0/17,162.158.0.0/15,104.16.0.0/12,172.64.0.0/13,131.0.72.0/22"

IFS=',' # Set comma as the delimiter
DOMAIN_INDEX=0
for DOMAIN in $DOMAINS; do
  TRAEFIK_CMD="$TRAEFIK_CMD --entrypoints.websecure.http.tls.domains[$DOMAIN_INDEX].main=$DOMAIN"
  TRAEFIK_CMD="$TRAEFIK_CMD --entrypoints.websecure.http.tls.domains[$DOMAIN_INDEX].sans=*.$DOMAIN"
  DOMAIN_INDEX=$((DOMAIN_INDEX + 1))
done

# Export the command to an environment variable
export TRAEFIK_CMD