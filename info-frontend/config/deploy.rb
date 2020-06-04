set :application, "info-frontend"
set :capfile_dir, File.expand_path("../", File.dirname(__FILE__))
set :server_class, "frontend"

load "defaults"
load "ruby"
load "deploy/assets"

set :rails_env, "production"
set :source_db_config_file, false
set :db_config_file, false
