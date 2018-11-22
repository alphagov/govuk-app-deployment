set :application, "email-alert-api"
set :capfile_dir, File.expand_path("../", File.dirname(__FILE__))
set :server_class, "email_alert_api"

set :do_upload_shared_config, true

set :run_migrations_by_default, true

load "defaults"
load "ruby"

after "deploy:restart", "deploy:restart_procfile_worker"
