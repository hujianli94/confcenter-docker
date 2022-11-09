Gitee::Application.configure do
    # Settings specified here will take precedence over those in config/application.rb.

    # Code is not reloaded between requests.
    config.cache_classes = true

    # Eager load code on boot. This eager loads most of Rails and
    # your application in memory, allowing both thread web servers
    # and those relying on copy on write to perform better.
    # Rake tasks automatically ignore this option for performance.
    config.eager_load = true

    # Full error reports are disabled and caching is turned on.
    config.consider_all_requests_local       = false
    config.action_controller.perform_caching = true

    # Enable Rack::Cache to put a simple HTTP cache in front of your application
    # Add `rack-cache` to your Gemfile before enabling this.
    # For large-scale production use, consider using a caching reverse proxy like nginx, varnish or squid.
    # config.action_dispatch.rack_cache = true
    # Disable serving static files from the `/public` folder by default since
    # Apache or NGINX already handles this.
    config.serve_static_files = true
    # Compress JavaScripts and CSS.
    config.assets.js_compressor = Uglifier.new(:harmony => true)
    config.assets.css_compressor = :sass

    # Do not fallback to assets pipeline if a precompiled asset is missed.
    config.assets.compile = true

    # Generate digests for assets URLs.
    config.assets.digest = true

    # Version of your assets, change this if you want to expire all your assets.
    config.assets.version = '1.0'

    # Specifies the header that your server uses for sending files.
    # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
    config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

    # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
    # config.force_ssl = true

    # Set to :debug to see everything in the log.
    config.log_level = :warn

    # Prepend all log lines with the following tags.
    # config.log_tags = [ :subdomain, :uuid ]

    # Use a different logger for distributed setups.
    # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

    # Use a different cache store in production.
    #config.cache_store = :redis_store, {url: 'redis://192.168.3.7:6379', expires_in: 1.day}
    config.cache_store = :redis_store, { cluster: %w[redis://redis-cluster-0.redis-cluster-headless.pub-comm:6379 redis://redis-cluster-1.redis-cluster-headless.pub-comm:6379 redis://redis-cluster-2.redis-cluster-headless.pub-comm:6379 redis://redis-cluster-3.redis-cluster-headless.pub-comm:6379 redis://redis-cluster-4.redis-cluster-headless.pub-comm:6379 redis://redis-cluster-5.redis-cluster-headless.pub-comm:6379], expires_in: 1.day }
    #config.redis = Redis.new(:url => 'redis://192.168.3.7:6379', :driver => :hiredis)
    config.redis = Redis.new(cluster: %w[redis://redis-cluster-0.redis-cluster-headless.pub-comm:6379 redis://redis-cluster-1.redis-cluster-headless.pub-comm:6379 redis://redis-cluster-2.redis-cluster-headless.pub-comm:6379 redis://redis-cluster-3.redis-cluster-headless.pub-comm:6379 redis://redis-cluster-4.redis-cluster-headless.pub-comm:6379 redis://redis-cluster-5.redis-cluster-headless.pub-comm:6379], driver: :hiredis)
    # 内容审查服务专用
    # config.redis_censoring = ActiveSupport::Cache::RedisStore.new(cluster: %w[], read_timeout: 0.1)
    config.memory_store = ActiveSupport::Cache::MemoryStore.new

    # TODO
    config.redis_cratos = Redis.new(:url => 'redis://redis-master.pub-comm.svc.cluster.local:6379', :driver => :hiredis)
    #config.redis_apk = Redis.new(:url => 'redis://192.168.2.52:6379', :driver => :hiredis)
    # Enable serving of images, stylesheets, and JavaScripts from an asset server.
    config.action_controller.asset_host = Proc.new { |source|
      if source =~ /assets|webpacks|uploads\/resources/
        Settings.gitee.assets_host
      end
    }

    # Precompile additional assets.
    # application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
    config.assets.precompile += %w(
                                    ace-editor/* editor.js editor.css ZeroClipboard.swf */app.js new-editor/* diffs/diffs.js skill_radar/*.js
                                    lib/jquery.timeago.*.js dropzone.js dropzone.css enterprises.css board.css ztree/* mobile/main.css mobile/enterprises.js
                                    home/application_oversea.css home/app_oversea.js
                                    admin/enterprise.css
                                    profiles/repo_info.js
                                    static/*
                                    app.css
                                    encrypt.js
                                    emoji/*
                                )

    # Disabled webpack dev server
    config.webpack.dev_server.enabled = false

    # Ignore bad email addresses and do not raise email delivery errors.
    # Set this to true and configure the email server for immediate delivery to raise delivery errors.
    # config.action_mailer.raise_delivery_errors = false

    # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
    # the I18n.default_locale when a translation can not be found).
    config.i18n.fallbacks = true

    # Send deprecation notices to registered listeners.
    config.active_support.deprecation = :notify

    # implict join call will raise mysql error if this config set to true
    config.active_record.disable_implicit_join_references = true

    # Disable automatic flushing of the log to improve performance.
    # config.autoflush_log = false

    # Use default logging formatter so that PID and timestamp are not suppressed.
    config.log_formatter = ::Logger::Formatter.new

    # Defaults to:
    # # config.action_mailer.sendmail_settings = {
    # #   :location => '/usr/sbin/sendmail',
    # #   :arguments => '-i -t'
    # # }
    #config.action_mailer.delivery_method = SendCloudDelivery
    #config.action_mailer.default_url_options = { host: 'gitlife.com' }

    # use system email service
    #config.action_mailer.delivery_method = :sendmail
    #config.action_mailer.perform_deliveries = true
    #config.action_mailer.raise_delivery_errors = true

    # 参数 url 需要跟 config.cache_store 里配置的 url 一致
    config.middleware.insert_after ActionDispatch::ParamsParser, '::Gitee::Middleware::DailyRateLimit', url: 'redis://redis-cluster.pub-comm.svc.cluster.local:6379/5', max_per_day: 60
    # use SASL send mail
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
        #address:              'smtp.sendcloud.net',
        #port:                  25,
        #domain:               'git.oschina.net',
        #user_name:            'oschina.user',
        #password:             'xxxxxxxxxxxxxxxx',
        #authentication:       'login',
        #enable_starttls_auto: true,
        #openssl_verify_mode:  0
        address: '172.18.0.39',
        port: 1025,
        domain: 'git.oschina.net',
        user_name: 'no-reply',
        password: '123456',
        authentication: 'plain',
        enable_starttls_auto: true,
        openssl_verify_mode: 'none'
    }
  end
