## RPI-Certbot-Manager 

Manage SSL certificates using Letsencrypt for Domains managed on Digitalocean

#### Requirements
* RaspberryPi
* Docker.
* Domain managed on Digitalocean.
* Digitalocean API access key.

### Installation

#### Download latest version

```console
$ wget -O rpi-certbot-manager-1.2.0.tar.gz https://github.com/tsrivishnu/rpi-certbot-manager/archive/v1.1.0.tar.gz && \
tar -xzvf rpi-certbot-manager-1.2.0.tar.gz && \
rm rpi-certbot-manager-1.2.0.tar.gz && \
cd rpi-certbot-manager-1.2.0
```

##### Digitalocean credentials

Use the template and create the credentials file.
```console
$ cp config/digitalocean.ini.example config/digitalocean.ini
```

Get the API access key from digitalocean and update the
`dns_digitalocean_token` variable in th credentials file.

##### Make config

The project uses `Makefile` to ease the process of certificate generation
and renewal.
It uses variables set in the file `config/.makeenv`.
Use the template and create the file:

```console
$ cp config/.makeenv.example config/.makeenv
```

Edit this `config/.makeenv` to match your requirements.

##### Certificate generation

```console
$ make generate-certificates
```

##### Cronjob to renew certificates

LetEncrypt issues certificates that are valid only for 90 days.
The certificates need to be renewed very often.
This project also includes the scripts to renew the certificates
using a `cron` job.
To install the cronjob. Simple run:

```console
$ make install-renewal-cron
```

###### Renew manual

If you choose not to renew automatically, you can also run the following:

```console
$ make renew
```

##### After success hooks

The project supports running bash scripts after generating and renewing the
certificates.
These bash script can be placed (or symlinked) in the `after-success-hooks`
directory.

#### Running in staging mode

```console
$ make STAGING=1 renew
```
