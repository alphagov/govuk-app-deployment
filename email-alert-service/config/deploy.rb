set :application, "email-alert-service"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, "backend"

load 'defaults'
load 'ruby'

set :copy_exclude, [
  '.git/*',
]

set :config_files_to_upload, {
  "secrets/to_upload/rabbitmq.yml.erb" => "config/rabbitmq.yml",
  "secrets/to_upload/redis.yml" => "config/redis.yml",
}

after "deploy:notify", "deploy:notify:error_tracker"
