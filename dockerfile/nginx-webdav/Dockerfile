FROM centos:centos7
LABEL auther="huxiaojian"

RUN set -ux;\
  sed -e 's!^#baseurl=!baseurl=!g' \
  -e  's!^mirrorlist=!#mirrorlist=!g' \
  -e 's!mirror.centos.org!mirrors.ustc.edu.cn!g' \
  -i  /etc/yum.repos.d/CentOS-Base.repo \
  && yum -y install epel-release; \
  yum -y install wget \
  gcc \
  make \
  pcre-devel \
  zlib-devel \
  openssl-devel \
  libxml2-devel \
  libxslt-devel \
  gd-devel \
  GeoIP-devel \
  jemalloc-devel \
  libatomic_ops-devel \
  perl-devel  \
  perl-ExtUtils-Embed \
  git \
  && mkdir /app



RUN git clone --depth 1 https://github.com/arut/nginx-dav-ext-module.git /app/nginx-dav-ext-module
RUN git clone --depth 1 https://github.com/openresty/headers-more-nginx-module.git /app/headers-more-nginx-module


RUN set -ux; \
  cd /app && wget http://nginx.org/download/nginx-1.22.0.tar.gz  && \
  tar zxmf nginx-1.22.0.tar.gz && \
  cd nginx-1.22.0 && \
  ./configure \
  --prefix=/usr/local/nginx \
  --with-threads \
  --with-file-aio \
  --with-http_ssl_module \
  --with-http_v2_module \
  --with-http_realip_module \
  --with-http_addition_module \
  --with-http_xslt_module=dynamic \
  --with-http_image_filter_module=dynamic \
  --with-http_geoip_module=dynamic \
  --with-http_sub_module \
  --with-http_dav_module --add-module=../nginx-dav-ext-module --add-module=../headers-more-nginx-module \
  --with-http_flv_module \
  --with-http_mp4_module \
  --with-http_gunzip_module \
  --with-http_gzip_static_module \
  --with-http_auth_request_module \
  --with-http_random_index_module \
  --with-http_secure_link_module \
  --with-http_degradation_module \
  --with-http_slice_module \
  --with-http_stub_status_module \
  --with-stream=dynamic \
  --with-stream_ssl_module \
  --with-stream_realip_module \
  --with-stream_geoip_module=dynamic \
  --with-stream_ssl_preread_module \
  --with-compat  \
  --with-pcre-jit \
  && make && make install \
  && rm -rf /app/nginx-1.22.0.tar.gz \
  && rm -rf /app/nginx-1.22.0


ENV PATH $PATH:/usr/local/nginx/sbin

RUN ln -sf /dev/stdout /usr/local/nginx/logs/access.log && \
  ln -sf /dev/stderr /usr/local/nginx/logs/error.log

RUN groupadd -g 1000 nginx; useradd -u 1000 -g nginx nginx && \
  chown -R 1000:1000 /usr/local/nginx && \
  cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo 'Asia/Shanghai'>/etc/timezone

WORKDIR /usr/local/nginx
USER nginx

EXPOSE 8080

ENTRYPOINT ["nginx", "-g", "daemon off;"]
