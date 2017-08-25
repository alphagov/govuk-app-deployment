require 'yaml'

set :application, "router-api"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, %w(draft_cache router_backend)

set :router_server_class, "cache"
set :router_reload_port, 3055

set :run_migrations_by_default, true

load 'defaults'
load 'ruby'

set :config_files_to_upload, {
  'secrets/to_upload/seeds/external_redirects.rb' => 'db/seeds/external_redirects.rb',
}

after "deploy:symlink", "deploy:create_mongoid_indexes"
after "deploy:symlink", "deploy:seed_db"
after "deploy:notify", "deploy:notify:error_tracker"
