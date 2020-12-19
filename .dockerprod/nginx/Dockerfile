FROM ruby:2.6.3-slim-buster
SHELL ["/bin/bash", "-c"]

ARG NGINX_VERSION=1.17.7

# Install dependencies
COPY ./Aptfile /tmp/Aptfile
RUN apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get -yq dist-upgrade && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    build-essential \
    $(cat /tmp/Aptfile | xargs) && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    truncate -s 0 /var/log/*log

RUN git clone https://github.com/matsumotory/ngx_mruby.git && \
    cd ngx_mruby && \
    sh ./build.sh

RUN wget https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz && \
    tar zxvf nginx-$NGINX_VERSION.tar.gz && \
    cd nginx-$NGINX_VERSION && \
    ./configure \
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-client-body-temp-path=/var/lib/nginx/body \
    --http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
    --http-log-path=/var/log/nginx/access.log \
    --http-proxy-temp-path=/var/lib/nginx/proxy \
    --lock-path=/var/lock/nginx.lock \
    --pid-path=/var/run/nginx.pid \
    --with-pcre-jit \
    --with-http_gzip_static_module \
    --with-http_ssl_module \
    --with-ipv6 \
    --without-http_browser_module \
    --with-http_geoip_module \
    --without-http_memcached_module \
    --without-http_referer_module \
    --without-http_scgi_module \
    --without-http_split_clients_module \
    --with-http_stub_status_module \
    --without-http_ssi_module \
    --without-http_userid_module \
    --without-http_uwsgi_module \
    --add-module=/ngx_mruby \
    --add-module=/ngx_mruby/dependence/ngx_devel_kit && \
    make && \
    make install && \
    make clean

RUN rm -rf /$NGINX_VERSION.tar.gz && \
    mkdir -p /var/lib/nginx

# Forward request logs to Docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80
EXPOSE 443
EXPOSE 8053

STOPSIGNAL SIGTERM

CMD [ "nginx", "-g", "daemon off;" ]
