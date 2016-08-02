set :application, "contacts-frontend"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, %w(draft_frontend frontend)

load 'defaults'
load 'ruby'

load 'deploy/assets'
set :assets_prefix, 'contacts-frontend'

set :source_db_config_file, false
set :db_config_file, false

set :config_files_to_upload, {
  "secrets/to_upload/secrets.yml" => "config/secrets.yml",
}

after "deploy:notify", "deploy:notify:errbit"
