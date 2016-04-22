set :application, "business-support-api"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, "backend"

load 'defaults'
load 'ruby'

set :source_db_config_file, false
set :db_config_file, false

after "deploy:upload_initializers", "deploy:symlink_mailer_config"
after "deploy:notify", "deploy:notify:errbit"
