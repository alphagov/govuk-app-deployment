set :application, "content-performance-manager"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, "backend"

set :run_migrations_by_default, true

load 'defaults'
load 'ruby'
load 'deploy/assets'

set :assets_prefix, 'content-performance-manager'
set :rails_env, 'production'
