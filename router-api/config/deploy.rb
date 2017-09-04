require 'yaml'

set :application, "router-api"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, %w(draft_cache router_backend)

set :router_server_class, "cache"
set :router_reload_port, 3055

set :run_migrations_by_default, true

load 'defaults'
load 'ruby'

after "deploy:symlink", "deploy:create_mongoid_indexes"
after "deploy:notify", "deploy:notify:error_tracker"
