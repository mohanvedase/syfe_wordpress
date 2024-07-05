FROM debian:stretch-slim

# Update the sources.list and install necessary packages
RUN sed -i 's/deb.debian.org/archive.debian.org/g' /etc/apt/sources.list && \
    sed -i 's/security.debian.org/deb.debian.org/g' /etc/apt/sources.list && \
    echo 'deb http://archive.debian.org/debian/ stretch main' > /etc/apt/sources.list.d/stretch.list && \
    apt-get update && \
    apt-get install -y \
    curl \
    libpcre3 \
    libpcre3-dev \
    libssl-dev \
    perl \
    make \
    build-essential \
    wget

# Set the OpenResty version
ENV OPENRESTY_VERSION="1.19.9.1"

# Download and build OpenResty with Lua
RUN wget https://openresty.org/download/openresty-${OPENRESTY_VERSION}.tar.gz && \
    tar -xzvf openresty-${OPENRESTY_VERSION}.tar.gz && \
    cd openresty-${OPENRESTY_VERSION} && \
    ./configure --prefix=/opt/openresty \
                --with-pcre-jit \
                --with-ipv6 \
                --without-http_redis2_module \
                --with-http_iconv_module \
                --with-http_postgres_module \
                -j8 && \
    make && make install && \
    cd .. && rm -rf openresty-${OPENRESTY_VERSION} openresty-${OPENRESTY_VERSION}.tar.gz

# Add OpenResty binaries to PATH
ENV PATH="/opt/openresty/bin:/opt/openresty/nginx/sbin:$PATH"

# Copy configuration files
COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf

# Expose ports
EXPOSE 80

# Start OpenResty
CMD ["nginx", "-g", "daemon off;"]