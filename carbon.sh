#!/bin/sh
exec /opt/graphite/bin/carbon-cache.py --debug --nodaemon start >> /srv/data/log/carbon.log 2>&1
