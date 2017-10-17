set :application, "specialist-publisher"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, "backend"

load 'defaults'
load 'ruby'
load 'deploy/assets'
load 'govuk_admin_template'

after "deploy:upload_initializers", "deploy:symlink_mailer_config"
after "deploy:symlink", "deploy:publishing_api:publish_special_routes"

after "deploy:restart", "deploy:restart_procfile_worker"
