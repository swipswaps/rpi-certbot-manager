include config/.makeenv
CREDENTIALS_FILE ?= /config/digitalocean.ini
ifeq ($(STAGING), 1)
	STAGING_ARG = --staging
endif

# Join the list of domains from +DOMAINS+ variable to generate the string that
# # is used to pass to the certbot scripts in the format
# # ```
# # certbot -d *.domain1.com -d *.domain2.com
# # ```
# # Join list elements according to
# # http://www.gnu.org/software/make/manual/make.html#Syntax-of-Functions
noop 	=
space = $(noop) $(noop)
DOMAINS_FOR_CERTBOT_ARGS = -d $(subst $(space), -d ,$(DOMAINS))

generate-certificates:
	docker run --rm --name certbot \
		-v "$(shell pwd)/letsencrypt:/letsencrypt" \
		-v "$(shell pwd)/config:/config" \
		tsrivishnu/for-rpi_alpine3.7_certbot-dns-digitalocean certonly $(STAGING_ARG) \
		--dns-digitalocean \
		--dns-digitalocean-credentials $(CREDENTIALS_FILE) \
				$(DOMAINS_FOR_CERTBOT_ARGS) \
        -m "$(EMAIL)" \
        --agree-tos --non-interactive --config-dir /letsencrypt --work-dir /letsencrypt

	bash $(shell pwd)/bin/run-after-success-hooks

renew:
	docker run --rm --name certbot \
		-v "$(shell pwd)/letsencrypt:/letsencrypt" \
		-v "$(shell pwd)/config:/config" \
		tsrivishnu/for-rpi_alpine3.7_certbot-dns-digitalocean renew $(STAGING_ARG) \
		--force-renewal \
		--dns-digitalocean \
		--dns-digitalocean-credentials $(CREDENTIALS_FILE) \
        --config-dir /letsencrypt --work-dir /letsencrypt

	bash $(shell pwd)/bin/run-after-success-hooks

install-renewal-cron:
	@echo "Adding cron job to run every 2nd month"
	@echo "0 0 1 */2 * root make -C $(PWD) renew >/tmp/certbot.log 2>&1" > certbot_renewal.cron
	sudo mv certbot_renewal.cron /etc/cron.d/certbot_renewal
	sudo chown root:root /etc/cron.d/certbot_renewal
	@echo "Cron installed at '/etc/cron.d/certbot_renewal'"

