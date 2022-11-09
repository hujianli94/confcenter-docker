```
unicorn&giteecron:
  configMap:
    5269_hengtuokaiyuan.key.p8    <binary>
    cert_2d59.crt    <binary>
    database.yml
    gitlab.yml
    redis.giteecron.yml
    shards.yml
    unicorn.rb
    environments/production.rb
    public/assets/manifest-hash.json
    public/webpacks/manifest.json
  emptyDir:
    log/
    tmp/

assets:
  configMap:
    /etc/nginx/
    /home/git/gitee.gpg
  emptyDir:
    /var/log/nginx/

pilot:
  configMap:
    config/http-pilot.yml
    config/ssh-pilot.yml
  emptyDir:
    logs/

svnsbz:
  configMap:
    config/svnsbz.toml
```