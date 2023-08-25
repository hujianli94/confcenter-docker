# 部署 confcenter-docker


confcenter(配置中心)由 nginx-webdavd 和 coder-server 组成。

- nginx-webdavd  文件上传下载服务器，提供配置文件的上传下载，以及当做NAS进行网络挂载。  

- coder-server   提供VScode的代码编写和权限控制。






## 1.部署nginx-webdavd和coder-server

```sh
$ git clone https://gitee.com/hujianli94net/confcenter-docker.git

$ cd confcenter-docker
$ chown -R 1000:1000 conf/
$ mkdir data
$ chown -R 1000:1000 data/
$ chmod -R  700 data/
```


制作镜像
```sh
# coder-server
$ cd confcenter-docker/dockerfile/code-server
$ docker build -t hub.gitee.com/autom-studio/coder-server:v4.13.0 .


# nginx-webdav
$ cd confcenter-docker/dockerfile/nginx-webdav
$ docker build -t hub.gitee.com/autom-studio/nginx-webdavd:v1.0.0 .

# 推送镜像
$ docker push hub.gitee.com/autom-studio/coder-server:v4.13.0
$ docker push hub.gitee.com/autom-studio/nginx-webdavd:v1.0.0 
```


## 2.开启htpasswd+nginx验证

```shell
# 可用于新增用户和添加用户
### 方法1
# apt install apache2-utils -y
# htpasswd -c /etc/nginx/conf/.davpasswd webdav ## webdav 为用户名


### 方法2
# 可以借助openssl去生成
# echo "webdav:$(openssl passwd 123123)" >/etc/nginx/conf/.davpasswd
```

> 注意

对于这种有HTTP Basic Authentication协议验证的页面，如果使用curl抓取的话，可以加上账号密码进行请求：

```shell
# curl
curl -u username:password URL

# wegt
wget --http-user= --http-passwd=passwd URL
```



[webdav核心配置文件](./conf/conf/conf.d/nginx-webdav.conf)




## 3.配置数据目录


软连接数据目录

```sh
# /data/nfs/目录为数据盘NFS目录
$ mkdir /data/nfs/confcenter-data/data/ -p

$ cd confcenter-docker/
$ ln -s /data/nfs/confcenter-data/data data
```

然后我们将配置文件中心的所有配置放置到当前目录下的data下。

示例如下

```bash

# tree -L 2 data
data
├── conf
│   └── projects
└── share
    └── gitee

$ chown -R 1000:1000 /data/nfs/confcenter-data/data/
$ chmod -R 700 /data/nfs/confcenter-data/data/

# 注意/data/nfs目录为一个nfs可共享的共享数据目录，后续可以将配置中心挂载到其他环境中。
```

需要将conf目录下的autoindex.html文件放置到配置中心的如下目录：

- data/conf/autoindex.html

- data/share/autoindex.html

这样文件服务器的美化autoindex显示就会正常，不会报出404的错误。







启动容器

-  [docker-compose.yml](./docker-compose.yml)



```yaml
  webdavd-conf:
  .....
    volumes:
      - ./conf/conf/:/usr/local/nginx/conf
      - ./data/conf/projects/:/usr/local/nginx/html:ro
  .....

  webdavd-share:
    .....
    volumes:
      - ./conf/share/:/usr/local/nginx/conf
      - ./data/share:/usr/local/nginx/html
  .....
```
webdavd-conf的挂载目录设置为只读模式，curl命令只能读取下载相关操作，不能上传、新建和修改。



```sh
# cd confcenter-docker
## 启动nginx-webdav和coder-server
$ docker-compose up -d
```





## 4.nginx反向代理配置


### code

conf/conf.d/code.conf

```conf
map $http_upgrade $connection_upgrade {
    default upgrade;
    '' close;
}

upstream code {
    server code:8080;
    keepalive 32;
}

server {
    listen 80;
    server_name code.autom.studio;
    access_log /var/log/nginx/code_302_access.log main;
    error_log /var/log/nginx/code_302_error.log;
    return 302 https://$server_name$request_uri;
}

server {
    include ssl.d/autom_ssl.conf;
    server_name code.autom.studio;
    access_log /var/log/nginx/code_access.log main;
    error_log /var/log/nginx/code_error.log;

    if ($http_user_agent ~ "MSIE" ) {
        return 303 https://browser-update.org/update.html;
    }

    location / {
        proxy_pass http://code;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
        proxy_set_header X-Forwarded-For $remote_addr;
        proxy_set_header Accept-Encoding gzip;
        proxy_set_header X-Frame-Options SAMEORIGIN;
    }

    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
        root /usr/share/nginx/html;
    }
}
```


### webdavd-conf

conf/conf.d/webdavd-conf.conf

```conf
upstream webdavd-conf {
    server webdavd-conf:8080;
    keepalive 32;
}

server {
    listen 80;
    server_name webdavd-conf.autom.studio;
    access_log /var/log/nginx/webdavd_conf_302_access.log main;
    error_log /var/log/nginx/webdavd_conf_302_error.log;
    return 302 https://$server_name$request_uri;
}

server {
    include ssl.d/autom_ssl.conf;
    server_name webdavd-conf.autom.studio;
    access_log /var/log/nginx/webdavd_conf_access.log main;
    error_log /var/log/nginx/webdavd_conf_error.log;

    if ($http_user_agent ~ "MSIE" ) {
        return 303 https://browser-update.org/update.html;
    }

    location / {
        proxy_pass http://webdavd-conf/;
        proxy_no_cache 1;
        proxy_cache_bypass 1;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header REMOTE-HOST $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_redirect off;
    }

    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
        root /usr/share/nginx/html;
    }
}

```



### webdavd-share

conf/conf.d/webdavd-share.conf

```conf
upstream webdavd-share {
    server webdavd-share:8080;
    keepalive 32;
}

server {
    listen 80;
    server_name webdavd-share.autom.studio;
    access_log /var/log/nginx/webdavd_share_302_access.log main;
    error_log /var/log/nginx/webdavd_share_302_error.log;
    return 302 https://$server_name$request_uri;
}

server {
    include ssl.d/autom_ssl.conf;
    server_name webdavd-share.autom.studio;
    access_log /var/log/nginx/webdavd_share_access.log main;
    error_log /var/log/nginx/webdavd_share_error.log;

    if ($http_user_agent ~ "MSIE" ) {
        return 303 https://browser-update.org/update.html;
    }

    location / {
        proxy_pass http://webdavd-share/;
        proxy_no_cache 1;
        proxy_cache_bypass 1;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header REMOTE-HOST $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_redirect off;
    }

    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
        root /usr/share/nginx/html;
    }
}

```




多级子目录做下载服务配置如下：

```conf
        location /conf/ {
            proxy_pass http://webdavd-conf/;
            proxy_redirect default;
            proxy_redirect / /conf/;
            proxy_no_cache 1;
            proxy_cache_bypass 1;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header REMOTE-HOST $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header Host $http_host;
        }

        location /share/ {
            proxy_pass http://webdavd-share/;
            proxy_redirect default;
            proxy_redirect / /share/;
            proxy_no_cache 1;
            proxy_cache_bypass 1;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header REMOTE-HOST $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header Host $http_host;
        }

```

多级子目录的autoindex.html文件目录配置如下

```
/workdir/docker-compose/confcenter-docker/data/conf# tree -L 2 projects/
projects/
├── autoindex.html
└── gitee
    ├── ansible

```

如下配置之后，web界面点击跳转就不会报404的错误，锁定根路径到`域名/conf/`和`域名/share/`

```js

        titlehtml = document.title.replace(/\/$/, '').split('/').slice(1).reduce(function(acc, v, i, a) {
                return acc + '<a href="/conf/' + a.slice(0, i+1).join('/') + '/">' + v + '</a>/'
        }, '<a href="/conf/">Index</a> of /conf/')

```




## 5.curl操作nginx-webdav

- 前提配置 host文件，域名对应nginx服务器的ip地址

```bash
# add(新建目录)--测试ok
# dns
curl -vX  MKCOL https://webdavd-share.autom.studio/test1  -u admin:${webdavd_passwd}
# ip
curl -vX  MKCOL http://172.18.0.95:8802/test2  -u admin:${webdavd_passwd}


# del(删除目录)--测试ok
# dns
curl -X DELETE -u admin:${webdavd_passwd}  https://webdavd-share.autom.studio/test1
# ip
curl -X DELETE -u admin:${webdavd_passwd}  http://172.18.0.95:8802/test2


# 读取文件--测试ok
# dns
curl http://172.18.0.95:8801/projects/gitee/k8s/prod/conf/unicorn/database.yml -u admin:${webdavd_passwd}
# ip
curl --user admin:${webdavd_passwd} https://webdavd-conf.autom.studio/projects/gitee/k8s/prod/conf/unicorn/database.yml


# download下载--测试ok
# dns
curl --user admin:${webdavd_passwd} https://webdavd-conf.autom.studio/projects/gitee/k8s/prod/conf/unicorn/database.yml > database.yml
# ip
curl --user admin:${webdavd_passwd} http://172.18.0.95:8801/projects/gitee/k8s/prod/conf/unicorn/database.yml > database.yml

# wget方式
wget -q --http-user=admin --http-password=${webdav_passwd} \
  http://172.18.0.95:8801/projects/gitee/k8s/prod/conf/unicorn/database.yml -O ./database.yml


# wget递归下载目录--测试ok
## 此方式下载会保留路径+文件。-cut-dirs=1去掉projects/
wget -r -nH -np --cut-dirs=1 --no-check-certificate -U Mozilla --user=admin  --password=${webdavd_passwd} http://172.18.0.95:8801/projects/gitee/k8s/prod/charts/gitee-sidekiq/values.yaml

# 下载chart包
wget -rq -np -nH -R "index.html*" -k -e robots=off --no-check-certificate -m --cut-dirs=6 --http-user=admin --http-password=${webdavd_passwd} \
  http://172.18.0.95:8801/projects/gitee/k8s/prod/charts/gitee-ssh-pilot/ -P ./gitee-ssh-pilot


# upload(上传文件)--测试ok
## 上传文件 -v显示详细，可以视情况去掉
curl -vT docker-compose.yml http://172.18.0.95:8802/gitee/ -u admin:${webdavd_passwd}
## 压缩包
## 显示上传进度
curl -T dockerfile.tar.gz http://172.18.0.95:8802/gitee/ -o dockerfile.tar.gz -u admin:${webdavd_passwd}


# rename(更名)--测试ok
# dns
curl -X MOVE --header 'Destination: https://webdavd-share.autom.studio/gitee/docker-compose.yml.template' 'https://webdavd-share.autom.studio/gitee/docker-compose.yml' -u admin:${webdavd_passwd}
# ip
curl -X MOVE --header 'Destination: http://172.18.0.95:8802/gitee/docker-compose.yml.template' 'http://172.18.0.95:8802/gitee/docker-compose.yml' -u admin:${webdavd_passwd}
```





**整理常用操作**

```shell
# 创建目录：
curl -X MKCOL -u <username>:<password> http://example.com/webdav/new_directory

# 上传文件：
curl -T <local_file_path> -u <username>:<password> http://example.com/webdav/

# 下载文件：
curl -O -u <username>:<password> http://example.com/webdav/file.txt

# 删除文件或目录：
curl -X DELETE -u <username>:<password> http://example.com/webdav/file.txt
```





## 6.客户端工具

> RaiDrive
> 
> 官方地址： http://www.raidrive.com/



## 7.拓展阅读

[nginx文件服务器美化autoindex显示](https://blog.csdn.net/witton/article/details/124780686)

[Nginx配置WebDav-制作私有网盘](https://www.jianshu.com/p/50cc357c4391)

[Nginx目录浏览基础与进阶](https://www.ssgeek.com/post/nginx-mu-lu-liu-lan-ji-chu-yu-jin-jie/)
