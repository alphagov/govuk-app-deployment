set :application, "short-url-manager"
set :capfile_dir, File.expand_path("../", File.dirname(__FILE__))
set :server_class, "backend"

set :run_migrations_by_default, false

load "defaults"
load "ruby"
load "deploy/assets"
load "govuk_admin_template"

set :whenever_command, "bundle exec whenever"
require "whenever/capistrano"

after "deploy:symlink", "deploy:create_mongoid_indexes"
after "deploy:restart", "deploy:restart_procfile_worker"
