set :application, "need-api"

set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, "backend"
set :repo_name, "govuk_need_api"

set :run_migrations_by_default, true

load 'defaults'
load 'ruby'

set :whenever_command, "bundle exec whenever"
require "whenever/capistrano"

set :rails_env, 'production'

after "deploy:notify", "deploy:notify:errbit"
