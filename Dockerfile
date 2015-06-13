FROM phusion/baseimage:0.9.16

CMD ["/sbin/my_init"]

ENV GRAPHITE_STORAGE_DIR="/srv/data/graphite"
ENV GRAPHITE_CONF_DIR="/opt/graphite/conf"
ENV DEBIAN_FRONTEND noninteractive

VOLUME /srv/data

# Install all prerequisites
RUN     apt-get -y install software-properties-common
RUN     add-apt-repository -y ppa:chris-lea/node.js
RUN     apt-get -y update
RUN     apt-get -y install python-django-tagging python-simplejson python-memcache python-ldap python-cairo python-pysqlite2 python-support \
                           python-pip gunicorn supervisor nginx-light nodejs git wget curl openjdk-7-jre build-essential python-dev

RUN     pip install Twisted==11.1.0
RUN     pip install Django==1.5
RUN     npm install ini chokidar

# Checkout the stable branches of Graphite, Carbon and Whisper and install from there
RUN     mkdir /src
RUN     git clone https://github.com/graphite-project/whisper.git /src/whisper            &&\
        cd /src/whisper                                                                   &&\
        git checkout 0.9.x                                                                &&\
        python setup.py install

RUN     git clone https://github.com/graphite-project/carbon.git /src/carbon              &&\
        cd /src/carbon                                                                    &&\
        git checkout 0.9.x                                                                &&\
        python setup.py install

RUN     git clone https://github.com/graphite-project/graphite-web.git /src/graphite-web  &&\
        cd /src/graphite-web                                                              &&\
        git checkout 0.9.x                                                                &&\
        python setup.py install

# Install StatsD
RUN     git clone https://github.com/etsy/statsd.git /srv/statsd                                                                        &&\
        cd /srv/statsd                                                                                                                  &&\
        git checkout v0.7.2

# Install Grafana
RUN     mkdir /src/grafana                                                                            &&\
        mkdir /opt/grafana                                                                            &&\
        wget grafanarel.s3.amazonaws.com/builds/grafana-2.0.2.linux-x64.tar.gz -O /src/grafana.tar.gz &&\
        tar -xzf /src/grafana.tar.gz -C /opt/grafana --strip-components=1                             &&\
        rm /src/grafana.tar.gz

RUN 	rm -fr /src

# Confiure StatsD
ADD     ./statsd/config.js /srv/statsd/config.js

# Configure Whisper, Carbon and Graphite-Web
ADD     ./graphite/initial_data.json /opt/graphite/webapp/graphite/initial_data.json
ADD     ./graphite/local_settings.py /opt/graphite/webapp/graphite/local_settings.py
ADD     ./graphite/carbon.conf /opt/graphite/conf/carbon.conf
ADD     ./graphite/storage-schemas.conf /opt/graphite/conf/storage-schemas.conf
ADD     ./graphite/storage-aggregation.conf /opt/graphite/conf/storage-aggregation.conf

# Configure Grafana
ADD     ./grafana/custom.ini /opt/grafana/conf/custom.ini

# Configure nginx
ADD     ./nginx/nginx.conf /etc/nginx/nginx.conf

# Configure services
RUN mkdir /etc/service/nginx
ADD		./nginx.sh /etc/service/nginx/run

RUN mkdir /etc/service/carbon
ADD		./carbon.sh /etc/service/carbon/run

RUN mkdir /etc/service/graphite
ADD		./graphite.sh /etc/service/graphite/run

RUN mkdir /etc/service/grafana
ADD		./grafana.sh /etc/service/grafana/run

RUN mkdir /etc/service/statsd
ADD		./statsd.sh /etc/service/statsd/run

RUN mkdir -p /etc/my_init.d
ADD init/setup_graphite.sh /etc/my_init.d/setup_graphite.sh

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Ports
EXPOSE 80
EXPOSE 8125/udp
EXPOSE 8126