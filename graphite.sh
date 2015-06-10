#!/bin/sh

export PYTHONPATH='/opt/graphite/webapp'

cd /opt/graphite/webapp

exec /usr/bin/gunicorn_django -b127.0.0.1:8000 -w2 graphite/settings.py >> /srv/data/log/graphite.log 2>&1
