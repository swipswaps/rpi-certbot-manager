# Changelog

## Unreleased

## 1.2.0 (2019-11-18)

* [Revert]: [Enhancement] Log entries are prepended with timestamp.
  * [Fix] Cron job doesn't run because output redirection is broken

## 1.1.0 (2019-08-31)

* [Feature] Log to +/var/log+ along with log rotation so that logs are kept longer.
* [Enhancement] Log entries are prepended with timestamp.
* [Enhancement] Check if renewal is needed before attempting renewal.
* [Enhancement] Cron now runs every sun, wed and fri on every 2nd month.
It will attempt to renew only if renewal is needed.

## 1.0.0 (2018-10-24)

* [Feature] Support multiple domains
* [Feature] Support after-success hooks
* [Feature] Ability to run in staging mode
