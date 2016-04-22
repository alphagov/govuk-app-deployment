set :application, "errbit"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, "exception_handler"

set :run_migrations_by_default, true

load 'defaults'
load 'ruby'
load 'deploy/assets'

after "deploy:upload_initializers", "deploy:symlink_mailer_config"
after "deploy:migrate", "deploy:create_mongoid_indexes"
