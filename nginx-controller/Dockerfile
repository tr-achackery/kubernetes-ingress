FROM nginx:1.13.3

# forward nginx access and error logs to stdout and stderr of the ingress
# controller process
RUN ln -sf /proc/1/fd/1 /var/log/nginx/access.log \
	&& ln -sf /proc/1/fd/2 /var/log/nginx/error.log

COPY nginx-ingress nginx/templates/nginx.ingress.tmpl nginx/templates/nginx.tmpl TR /

RUN rm /etc/nginx/conf.d/*

RUN mkdir -p /etc/nginx/secrets

RUN apt-get update
RUN apt-get -y install libssl-dev libpcre3 libpcre3-dev zlib1g-dev wget tar build-essential ca-certificates
RUN wget -O njs.tar.gz http://hg.nginx.org/njs/archive/tip.tar.gz && \
    wget -O nginx.tar.gz https://nginx.org/download/nginx-1.13.3.tar.gz && \
    tar xzvf njs.tar.gz && \
    tar xzvf nginx.tar.gz && \
    cd nginx-* && ./configure --with-compat --add-dynamic-module=../njs*/nginx && \
    make && make install && \
    mv /nginx-1.13.3/objs/ngx_http_js_module.so /etc/nginx/modules/ && \
    rm -f ../*.tar.gz

# Uncomment the line below if you would like to add the default.pem to the image
# and use it as a certificate and key for the default server
# ADD default.pem /etc/nginx/secrets/default

ENTRYPOINT ["/nginx-ingress"]
