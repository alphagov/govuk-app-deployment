set :application, "tariff"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, "calculators_frontend"
set :repo_name, "trade-tariff-frontend"

set :source_db_config_file, false
set :db_config_file, false

load 'defaults'
load 'ruby'
load 'deploy/assets'

set :rails_env, 'production'
set :bundle_without, [:development, :test, :webkit]

set :copy_exclude, [
  '.git/*',
  'public/images',
  'public/javascripts',
  'public/stylesheets',
  'public/templates'
]

after "deploy:symlink", "deploy:publishing_api:publish_special_routes"
after "deploy:upload_initializers", "deploy:symlink_mailer_config"
after "deploy:notify", "deploy:notify:errbit"
