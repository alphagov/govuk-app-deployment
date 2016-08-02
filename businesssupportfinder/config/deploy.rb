set :application, "businesssupportfinder"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, "calculators_frontend"
set :repo_name, "business-support-finder"

load 'defaults'
load 'ruby'
load 'deploy/assets'

set :assets_prefix, 'businesssupportfinder'
set :rails_env, 'production'
set :source_db_config_file, false
set :db_config_file, false

after "deploy:symlink", "deploy:panopticon:register"
after "deploy:symlink", "deploy:publishing_api:publish"
after "deploy:notify", "deploy:notify:errbit"
