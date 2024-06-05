
# Setup

### Create a proxy network for traefik
```bash
docker network create proxy
```

### Install htpasswd
```bash
brew install httpd
```

### Generate a password
```bash
htpasswd -nb username password
```
This command will output a line that looks like:
username:$apr1$randomstring$hashedpassword




# Cloudflare Setup
If using cloudflare, you must have strict domains set for all domains