include config/.makeenv
CREDENTIALS_FILE ?= /config/digitalocean.ini
ifeq ($(STAGING), 1)
	STAGING_ARG = --staging
endif

DOCKER_RUN_CERTBOT ?= docker run --rm --name certbot -v "$(shell pwd)/letsencrypt:/letsencrypt" -v "$(shell pwd)/config:/config" tsrivishnu/for-rpi_alpine3.7_certbot-dns-digitalocean --dns-digitalocean --dns-digitalocean-credentials $(CREDENTIALS_FILE) --config-dir /letsencrypt --work-dir /letsencrypt

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
	$(DOCKER_RUN_CERTBOT) certonly $(STAGING_ARG) \
				$(DOMAINS_FOR_CERTBOT_ARGS) \
        -m "$(EMAIL)" --agree-tos --non-interactive

	bash $(shell pwd)/bin/run-after-success-hooks

renew:
	$(DOCKER_RUN_CERTBOT) renew $(STAGING_ARG)

	bash $(shell pwd)/bin/run-after-success-hooks

install-logrotation:
	@echo "=> Installing log rotation config..."
	sudo mkdir -p /var/log/certbot-manager/
	sudo cp $(shell pwd)/config/logrotate /etc/logrotate.d/certbot-manager
	sudo chown 0:0 /etc/logrotate.d/certbot-manager
	sudo chmod 644 /etc/logrotate.d/certbot-manager

test:
	echo $(DOMAINS)

install-renewal-cron: install-logrotation
	@echo "==> Adding cron job to run every SUN, WED, FRI of every 2nd month..."
	@echo "0 0 * */2 0,3,5 root make -C $(PWD) renew >> /var/log/certbot-manager/certbot.log 2>&1" > certbot_renewal.cron
	sudo mv certbot_renewal.cron /etc/cron.d/certbot_renewal
	sudo chown root:root /etc/cron.d/certbot_renewal
	@echo "Cron installed at '/etc/cron.d/certbot_renewal'"

