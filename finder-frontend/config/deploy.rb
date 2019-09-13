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

# https://github.com/javan/whenever#capistrano-integration
require "whenever/capistrano"
set :whenever_command, "govuk_setenv finder-frontend bundle exec whenever"

namespace :deploy do
  task :update_registries_cache do
    run "cd #{current_release}; #{rake} RACK_ENV=#{rack_env} registries:cache_warm"
  end

  task :update_content_items_cache do
    run "cd #{current_release}; #{rake} RACK_ENV=#{rack_env} content_store:refresh_cache_soft"
  end
end

after "deploy:finalize_update", "deploy:update_registries_cache", "deploy:update_content_items_cache"
