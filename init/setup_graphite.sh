#!/bin/bash

if [ ! -f /srv/data/graphite/graphite.db ];
then
    mkdir -p /srv/data/graphite/whisper /srv/data/graphite/log/webapp
    touch /srv/data/graphite/graphite.db /srv/data/graphite/index
    chown -R www-data /srv/data/graphite
    chmod 0775 /srv/data/graphite
    chmod 0775 /srv/data/graphite/whisper
    chmod 0664 /srv/data/graphite/graphite.db
    cd /opt/graphite/webapp/graphite && python manage.py syncdb --noinput
fi

if [ ! -f /srv/data/log ];
then
    mkdir -p /srv/data/log
fi
