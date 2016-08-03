set :application, "search-admin"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, "backend"

set :run_migrations_by_default, true

load 'defaults'
load 'ruby'
load 'deploy/assets'

set :source_db_config_file, 'secrets/to_upload/database.yml'

set :config_files_to_upload, {
  'secrets/to_upload/secrets.yml' => 'config/secrets.yml'
}

set :copy_exclude, [
  '.git/*',
  'public/images',
  'public/javascripts',
  'public/stylesheets',
  'public/templates'
]

after "deploy:notify", "deploy:notify:errbit"
