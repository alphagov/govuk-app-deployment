set :application, "hmrc-manuals-api"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, "backend"

load 'defaults'
load 'ruby'

set :config_files_to_upload, {
  'secrets/to_upload/redis.yml' => 'config/redis.yml',
}

after "deploy:restart", "deploy:restart_procfile_worker"
after "deploy:notify", "deploy:notify:errbit"
