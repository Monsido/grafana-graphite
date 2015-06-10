#!/bin/sh
cd /opt/grafana/
exec /opt/grafana/bin/grafana-server >> /srv/data/log/grafana.log 2>&1
