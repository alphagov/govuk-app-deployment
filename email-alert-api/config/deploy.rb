set :application, "email-alert-api"
set :capfile_dir, File.expand_path("../", File.dirname(__FILE__))
set :server_class, "backend"

set :run_migrations_by_default, true

load "defaults"
load "ruby"

set :whenever_command, "govuk_setenv email-alert-api bundle exec whenever"
require "whenever/capistrano"

after "deploy:restart", "deploy:restart_procfile_worker"
