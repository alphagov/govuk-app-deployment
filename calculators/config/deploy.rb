set :application,        "calculators"
set :capfile_dir,        File.expand_path('../', File.dirname(__FILE__))
set :server_class,       "calculators_frontend"

load 'defaults'
load 'ruby'

load 'deploy/assets'
set :assets_prefix, 'calculators'

set :db_config_file, false
set :rails_env, 'production'
set :source_db_config_file, false

after "deploy:upload_initializers", "deploy:symlink_mailer_config"
after "deploy:symlink", "deploy:panopticon:register"
after "deploy:symlink", "deploy:rummager:index_all"
after "deploy:symlink", "deploy:publishing_api:publish"
after "deploy:notify", "deploy:notify:errbit"
