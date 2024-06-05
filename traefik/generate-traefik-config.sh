e.storage=/letsencrypt/acme.json
      - --certificatesresolvers.le.acme.dnschallenge.resolvers=1.1.1.1:53,8.8.8.8:53
      # Set up the TLS configuration for our websecure listener (basically gives wildcard cert for the main domain)
      - --entrypoints.websecure.http.tls=true
      - --entrypoints.websecure.http.tls.certResolver=le
      - --entrypoints.websecure.http.tls.domains[0].main=${MAIN_DOMAIN}
      - --entrypoints.websecure.http.tls.domains[0].sans=*.${MAIN_DOMAIN}

      - --entrypoints.websecure.http.tls.domains[1].main=basketwhisperer.com
      - --entrypoints.websecure.http.tls.domains[1].sans=*.basketwhisperer.com
      - --entrypoints.websecure.http.tls.domains[2].main=chatgptbeat.com
      - --entrypoints.websecure.http.tls.domains[2].sans=*.chatgptbeat.com

      # Allow these IPs to set the X-Forwarded-* headers - Cloudflare IPs: https://www.cloudflare.com/ips/
      - --entrypoints.web.forwardedHeaders.trustedIPs=173.245.48.0/20,103.21.244.0/22,103.22.200.0/22,103.31.4.0/22,141.101.64.0/18,108.162.192.0/18,190.93.240.0/20,188.114.96.0/20,197.234.240.0/22,198.41.128.0/17,162.158.0.0/15,104.16.0.0/12,172.64.0.0/13,131.0.72.0/22

    environment:
      - CF_API_EMAIL=${CF_API_EMAIL}
      - CF_DNS_API_TOKEN=${CF_DNS_API_TOKEN}
    ports:
      - 80:80
      - 443:443
    volumes:
      # To persist certificates
      - /var/lib/docker/volumes/traefik/_data/letsencrypt:/letsencrypt
      # So that Traefik can listen to the Docker events
      - /var/run/docker.sock:/var/run/docker.sock:ro
    networks:
      - proxy

    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.traefik-dash.rule=Host(`${MANAGE_DOMAIN}`)"
      - "traefik.http.routers.traefik-dash.entrypoints=websecure"
      - "traefik.http.routers.traefik-dash.service=api@internal"
      - "traefik.http.routers.traefik-dash.middlewares=traefik-auth"
      - "traefik.http.middlewares.traefik-auth.basicauth.users=${BASIC_AUTH_USERNAME}:${BASIC_AUTH_PASSWORD_HASH}"

networks:
  proxy:
    external: true
```
How can I add entrypoints.websecure.http.tls.domains[x] entries dynamic. For example instead of having
```
      - --entrypoints.websecure.http.tls.domains[0].main=${MAIN_DOMAIN}
      - --entrypoints.websecure.http.tls.domains[0].sans=*.${MAIN_DOMAIN}

      - --entrypoints.websecure.http.tls.domains[1].main=basketwhisperer.com
      - --entrypoints.websecure.http.tls.domains[1].sans=*.basketwhisperer.com
      - --entrypoints.websecure.http.tls.domains[2].main=chatgptbeat.com
      - --entrypoints.websecure.http.tls.domains[2].sans=*.chatgptbeat.com
```
I set the domains basketwhisperer.com and chatgptbeat.com as an .env value. This should be able to suport any number of domains

2 / 2

profile
Gpt-4o 04/06/2024 22:57
To achieve dynamic handling of multiple domain entries, you can use environment variables in combination with a script to dynamically generate the appropriate command flags when the container starts. Here’s an approach to accomplish this:



Update the docker-compose.yml file:
Modify the docker-compose.yml to add a script that will generate the necessary command arguments for the domains.
version: '3'

services:
  reverse-proxy:
    image: traefik:latest
    restart: unless-stopped
    entrypoint: ["/bin/sh", "-c", "/generate-traefik-config.sh && traefik"]
    environment:
      - CF_API_EMAIL=${CF_API_EMAIL}
      - CF_DNS_API_TOKEN=${CF_DNS_API_TOKEN}
      - LE_EMAIL=${LE_EMAIL}
      - DOMAINS=${DOMAINS}
    ports:
      - 80:80
      - 443:443
    volumes:
      # To persist certificates
      - /var/lib/docker/volumes/traefik/_data/letsencrypt:/letsencrypt
      # So that Traefik can listen to the Docker events
      - /var/run/docker.sock:/var/run/docker.sock:ro
      # Custom script to generate config
      - ./generate-traefik-config.sh:/generate-traefik-config.sh
    networks:
      - proxy
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.traefik-dash.rule=Host(`${MANAGE_DOMAIN}`)"
      - "traefik.http.routers.traefik-dash.entrypoints=websecure"
      - "traefik.http.routers.traefik-dash.service=api@internal"
      - "traefik.http.routers.traefik-dash.middlewares=traefik-auth"
      - "traefik.http.middlewares.traefik-auth.basicauth.users=${BASIC_AUTH_USERNAME}:${BASIC_AUTH_PASSWORD_HASH}"

networks:
  proxy:
    external: true


Create the generate-traefik-config.sh script:
This script will be responsible for generating the required Traefik configuration based on the environment variables.
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