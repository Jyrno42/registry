FROM ruby:2.2.5

# Purge apache
RUN apt-get purge -y apache*

ENV HTTPD_PREFIX /usr/local/apache2
ENV PATH $HTTPD_PREFIX/bin:$PATH
RUN mkdir -p "$HTTPD_PREFIX" \
	&& chown www-data:www-data "$HTTPD_PREFIX"
WORKDIR $HTTPD_PREFIX

# install httpd runtime dependencies
# https://httpd.apache.org/docs/2.4/install.html#requirements
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		libapr1 \
		libaprutil1 \
		libaprutil1-ldap \
		libapr1-dev \
		libaprutil1-dev \
		libpcre++0 \
		libssl1.0.0 \
	&& rm -r /var/lib/apt/lists/*

ENV HTTPD_VERSION 2.4.23
ENV HTTPD_SHA1 5101be34ac4a509b245adb70a56690a84fcc4e7f

# https://issues.apache.org/jira/browse/INFRA-8753?focusedCommentId=14735394#comment-14735394
ENV HTTPD_BZ2_URL https://www.apache.org/dyn/closer.cgi?action=download&filename=httpd/httpd-$HTTPD_VERSION.tar.bz2
# not all the mirrors actually carry the .asc files :'(
ENV HTTPD_ASC_URL https://www.apache.org/dist/httpd/httpd-$HTTPD_VERSION.tar.bz2.asc

# see https://httpd.apache.org/docs/2.4/install.html#requirements
RUN set -x \
	&& buildDeps=' \
		bzip2 \
		ca-certificates \
		gcc \
		libpcre++-dev \
		libssl-dev \
		make \
		wget \
	' \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends $buildDeps \
	&& rm -r /var/lib/apt/lists/* \
	\
	&& wget -O httpd.tar.bz2 "$HTTPD_BZ2_URL" \
	&& echo "$HTTPD_SHA1 *httpd.tar.bz2" | sha1sum -c - \
# see https://httpd.apache.org/download.cgi#verify
	&& wget -O httpd.tar.bz2.asc "$HTTPD_ASC_URL" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys A93D62ECC3C8EA12DB220EC934EA76E6791485A8 \
	&& gpg --batch --verify httpd.tar.bz2.asc httpd.tar.bz2 \
	&& rm -r "$GNUPGHOME" httpd.tar.bz2.asc \
	\
	&& mkdir -p src \
	&& tar -xvf httpd.tar.bz2 -C src --strip-components=1 \
	&& rm httpd.tar.bz2 \
	&& cd src \
	\
	&& ./configure \
		--prefix="$HTTPD_PREFIX" \
		--enable-mods-shared=reallyall \
	&& make -j"$(nproc)" \
	&& make install \
	\
	&& cd .. \
	&& rm -r src \
	\
	&& sed -ri \
		-e 's!^(\s*CustomLog)\s+\S+!\1 /proc/self/fd/1!g' \
		-e 's!^(\s*ErrorLog)\s+\S+!\1 /proc/self/fd/2!g' \
		"$HTTPD_PREFIX/conf/httpd.conf"

COPY dockerized/httpd-foreground /usr/local/bin/

# Install phusion-passenger
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
RUN apt-get update
RUN apt-get install -y apt-transport-https ca-certificates
RUN echo "deb https://oss-binaries.phusionpassenger.com/apt/passenger jessie main" > /etc/apt/sources.list.d/passenger.list
RUN apt-get update
RUN apt-get install -y libapache2-mod-passenger
RUN cat /etc/apache2/mods-available/passenger.load >> conf/httpd.conf
RUN cat /etc/apache2/mods-available/passenger.conf >> conf/httpd.conf

# Install postgres
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main 9.5" >> /etc/apt/sources.list.d/postgresql.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN apt-get update && apt-get install -y postgresql-client-9.5

# Install mod_epp
RUN apt-get install -y apache2-threaded-dev
RUN wget https://sourceforge.net/projects/aepps/files/mod_epp/1.10/mod_epp-1.10.tar.gz && tar -xzvf mod_epp-1.10.tar.gz
RUN cd mod_epp-1.10 && \
    wget https://github.com/internetee/registry/raw/master/doc/patches/mod_epp_1.10-rack-friendly.patch && \
    wget https://raw.githubusercontent.com/domify/registry/master/doc/patches/mod_epp_1.10-frame-size.patch && \
    patch < mod_epp_1.10-rack-friendly.patch && \
    patch < mod_epp_1.10-frame-size.patch && \
    apxs2 -c -i mod_epp.c && \
    cd .. && \
    mv /usr/lib/apache2/modules/mod_epp.so /usr/local/apache2/modules/mod_epp.so && \
    rm -rf mod_epp-1.10.tar.gz && rm -rf mod_epp-1.10
RUN echo "LoadModule epp_module modules/mod_epp.so" >> /usr/local/apache2/conf/httpd.conf

# Enable ssl module
RUN sed -i -e 's/#LoadModule ssl_module/LoadModule ssl_module/g' /usr/local/apache2/conf/httpd.conf
RUN sed -i -e 's/#LoadModule proxy_module/LoadModule proxy_module/g' /usr/local/apache2/conf/httpd.conf
RUN sed -i -e 's/#LoadModule proxy_http_module/LoadModule proxy_http_module/g' /usr/local/apache2/conf/httpd.conf
RUN sed -i -e 's/#LoadModule rewrite_module/LoadModule rewrite_module/g' /usr/local/apache2/conf/httpd.conf

# Configure openssl
ENV EIS_CA_DIR /home/registry/registry/shared/ca
ADD dockerized/openssl.cnf /etc/ssl/openssl.cnf

# Create apache certificates
RUN mkdir -p /etc/apache2/ssl
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/apache2/ssl/apache.key \
    -batch \
    -out /etc/apache2/ssl/apache.crt \
    -subj "/C=EE/ST=/L=/O=/CN=eis.local"

# Add some scripts
ADD dockerized/configure-certificates.sh /configure-certificates.sh
ADD dockerized/configure-esteid.sh /configure-esteid.sh
ADD dockerized/wait-for-it.sh /wait-for-it.sh
ADD dockerized/docker-entrypoint.sh /docker-entrypoint.sh

# Configure esteid
RUN /configure-esteid.sh

# Install app
RUN mkdir -p /home/registry/registry
WORKDIR /home/registry/registry
ENV RAILS_ENV staging
ADD Gemfile /home/registry/registry/Gemfile
ADD Gemfile.lock /home/registry/registry/Gemfile.lock
RUN bundle install
ADD . /home/registry/registry

# Add configuration files
ADD dockerized/database.yml /home/registry/registry/config/database.yml
ADD dockerized/application.yml /home/registry/registry/config/application.yml

# Add configuration files from templates
ADD config/secrets-example.yml /home/registry/registry/config/secrets.yml

# Replace some values inside configs
RUN sed -i -e 's/localhost/db/g' /home/registry/registry/config/database.yml

# Add vhost configs
RUN echo "Include conf/registry.conf" >> /usr/local/apache2/conf/httpd.conf
ADD dockerized/registry.conf /usr/local/apache2/conf/registry.conf

# Run apache as www-data
RUN sed -i -e 's/User daemon/User www-data/g' /usr/local/apache2/conf/httpd.conf
RUN sed -i -e 's/Group daemon/Group www-data/g' /usr/local/apache2/conf/httpd.conf

# Create runtime directories (and set correct ownership)
RUN mkdir -p /home/registry/registry/log
RUN mkdir -p /home/registry/registry/tmp
RUN touch /home/registry/registry/log/newrelic_agent.log
RUN touch /home/registry/registry/log/webservices.log

# Configure directory permissions (note: these are quite loose...)
RUN chown -R www-data:www-data .; chmod -R 750 .; chmod g+s .; umask 027
RUN chmod -R g+w /home/registry/registry/log
RUN chmod -R g+w /home/registry/registry/tmp

# Disable ActiveSupport logger
RUN sed -i -e 's/config\.logger \= ActiveSupport/#config\.logger \= ActiveSupport/g' /home/registry/registry/config/environments/staging.rb

# Reduce image size
RUN apt-get remove -y \
    bzip2 \
    gcc \
    make \
    libssl-dev \
    libpcre++-dev \
    apt-transport-https \
    wget
RUN apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# ENTRYPOINT and CMD
ENTRYPOINT /wait-for-it.sh ${EIS_DATABASE_HOST}:5432 -- /docker-entrypoint.sh
