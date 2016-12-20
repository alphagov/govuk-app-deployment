set :application, "service-manual-publisher"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, "backend"

set :run_migrations_by_default, true

load 'defaults'
load 'ruby'
load 'deploy/assets'
load 'govuk_admin_template'

after "deploy:upload_initializers", "deploy:symlink_mailer_config"
after "deploy:notify", "deploy:notify:errbit"
