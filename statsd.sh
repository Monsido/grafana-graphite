#!/bin/sh
exec /usr/bin/node /srv/statsd/stats.js /srv/statsd/config.js >> /srv/data/log/statsd.log 2>&1
