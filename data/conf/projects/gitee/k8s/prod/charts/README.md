```
helm -n gitee-prod upgrade gitee-assets -f ./gitee-assets/values.yaml ./gitee-assets
helm -n gitee-prod upgrade gitee-authunicorn -f ./gitee-authunicorn/values.yaml ./gitee-authunicorn
helm -n gitee-prod upgrade gitee-giteecron -f ./gitee-giteecron/values.yaml ./gitee-giteecron
helm -n gitee-prod upgrade gitee-graphqlunicorn -f ./gitee-graphqlunicorn/values.yaml ./gitee-graphqlunicorn
helm -n gitee-prod upgrade gitee-community-web -f gitee-community-web/values.yaml ./gitee-community-web
helm -n gitee-prod upgrade gitee-assets -f gitee-assets/values.yaml ./gitee-assets
helm -n gitee-prod upgrade gitee-authunicorn -f gitee-authunicorn/values.yaml ./gitee-authunicorn
helm -n gitee-prod upgrade gitee-sidekiq -f ./gitee-sidekiq/values.yaml ./gitee-sidekiq
helm -n gitee-prod upgrade gitee-webunicorn -f ./gitee-webunicorn/values.yaml ./gitee-webunicorn
```
