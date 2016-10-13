set :application, "panopticon"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, "backend"

set :run_migrations_by_default, true

load 'defaults'
load 'ruby'
load 'deploy/assets'

load 'govuk_admin_template'

set :rails_env, 'production'

set :copy_exclude, [
  'public/images',
  'public/javascripts',
  'public/stylesheets',
  'public/templates'
]

after "deploy:migrate", "deploy:create_mongoid_indexes"
after "deploy:symlink", "deploy:seed_db"
after "deploy:notify", "deploy:notify:errbit"
after "deploy:restart", "deploy:restart_procfile_worker"
