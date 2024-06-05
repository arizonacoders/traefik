# Setup

## Prerequisites
1. Docker
2. Docker Compose
3. A Cloudflare account (if using Cloudflare for DNS)

## Create a proxy network for Traefik

Create a Docker network named `proxy` that will be used by Traefik:

```bash
docker network create proxy
```

## Install htpasswd

Install `htpasswd` using your package manager. For macOS you can use Homebrew:

```bash
brew install httpd
```

For Ubuntu/Debian:

```bash
sudo apt-get update
sudo apt-get install apache2-utils
```

For CentOS/RHEL:

```bash
sudo yum install httpd-tools
```

## Generate a password

Generate a hashed password using `htpasswd`. Replace `username` and `password` with your desired credentials:

```bash
htpasswd -nb username password
```

This command will output a line that looks like:

```
username:$apr1$randomstring$hashedpassword
```

Add the generated line to your `traefik/.env` file:

```plaintext
BASIC_AUTH_USERNAME=username
BASIC_AUTH_PASSWORD_HASH=$apr1$randomstring$hashedpassword
```

## Cloudflare Setup

If using Cloudflare, ensure that you have strict TLS settings configured for all domains:

1. Log in to your Cloudflare account.
2. Go to the SSL/TLS settings for each domain.
3. Set the SSL option to "Full (Strict)".

Ensure your `CF_API_EMAIL` and `CF_DNS_API_TOKEN` are also set in the `traefik/.env` file:

```plaintext
CF_API_EMAIL=your-cloudflare-email
CF_DNS_API_TOKEN=your-cloudflare-dns-token
LE_EMAIL=your-email-for-letsencrypt
DOMAINS=example.com,example2.com,example3.com
```

## Running Traefik

Once you have your `.env` file properly configured and your Docker network created, you can start Traefik using Docker Compose.

To start Traefik, run:

```bash
cd traefik && \
docker-compose up -d && \
cd ..
```

## Launch the Open Web-UI

Create a new .env file in the `open-webui` directory.

Navigate to the `open-webui` directory and run Docker Compose:

```bash
cd ../open-webui
docker-compose up -d
```
This will start the Traefik service and configure it dynamically based on your `.env` file settings.

## Additional Resources

- [Open Web-UI Documentation](https://docs.openwebui.com/)
- [Traefik Documentation](https://doc.traefik.io/traefik/)
- [Cloudflare Documentation](https://developers.cloudflare.com/docs/)
