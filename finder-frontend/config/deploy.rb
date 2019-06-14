set :application, "finder-frontend"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, "calculators_frontend"

load 'defaults'
load 'ruby'
load 'deploy/assets'

set :assets_prefix, 'finder-frontend'
set :rails_env, 'production'
set :source_db_config_file, false
set :db_config_file, false

namespace :deploy do
  task :update_registries_cache do
    run "cd #{current_release}; #{rake} RACK_ENV=#{rack_env} registries:cache_refresh"
  end
end

after "deploy:finalize_update", "deploy:update_registries_cache"
