include config/.makeenv
CREDENTIALS_FILE ?= /config/digitalocean.ini

generate-certificates:
	docker run -it --rm --name certbot \
		-v "$(shell pwd)/letsencrypt:/letsencrypt" \
		-v "$(shell pwd)/config:/config" \
		tsrivishnu/for-rpi_alpine3.7_certbot-dns-digitalocean certonly --dns-digitalocean \
		--dns-digitalocean-credentials $(CREDENTIALS_FILE) \
        -d $(DOMAIN) \
        -m "$(EMAIL)" \
        --agree-tos --non-interactive --config-dir /letsencrypt --work-dir /letsencrypt 
renew:
	docker run --rm --name certbot \
		-v "$(shell pwd)/letsencrypt:/letsencrypt" \
		-v "$(shell pwd)/config:/config" \
		tsrivishnu/for-rpi_alpine3.7_certbot-dns-digitalocean renew --force-renewal --dns-digitalocean \
		--dns-digitalocean-credentials $(CREDENTIALS_FILE) \
        --config-dir /letsencrypt --work-dir /letsencrypt 

install-renewal-cron:
	@echo "Adding crontab"
	@echo "*/1 * * * * pi make -C $(PWD) renew >/tmp/certbot.log 2>&1" > certbot_renewal.cron
	sudo mv certbot_renewal.cron /etc/cron.d/certbot_renewal
	sudo chown root:root /etc/cron.d/certbot_renewal
	@echo "Cron installed at '/etc/cron.d/certbot_renewal'"

