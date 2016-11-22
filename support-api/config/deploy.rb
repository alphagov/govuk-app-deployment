set :application, "support-api"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, "backend"

set :run_migrations_by_default, true

load 'defaults'
load 'ruby'

set :whenever_command, "bundle exec whenever"
require "whenever/capistrano"

after "deploy:restart", "deploy:restart_procfile_worker"
after "deploy:notify", "deploy:notify:errbit"
after "deploy:upload_initializers", "deploy:symlink_mailer_config"
