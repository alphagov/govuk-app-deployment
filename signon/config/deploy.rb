set :application, "signon"
set :capfile_dir, File.expand_path("../", File.dirname(__FILE__))
set :server_class, "backend"

set :run_migrations_by_default, true

load "defaults"
load "ruby"
load "deploy/assets"

load "govuk_admin_template"

require "whenever/capistrano"
set :whenever_command, "govuk_setenv signon bundle exec whenever"

after "deploy:upload_initializers", "deploy:symlink_mailer_config"
after "deploy:restart", "deploy:restart_procfile_worker"
