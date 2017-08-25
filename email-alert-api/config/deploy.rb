set :application, "email-alert-api"
set :capfile_dir, File.expand_path("../", File.dirname(__FILE__))
set :server_class, "backend"

set :run_migrations_by_default, true

load "defaults"
load "ruby"

set :config_files_to_upload, {
  "secrets/to_upload/redis.yml" => "config/redis.yml",
  "secrets/to_upload/secrets.yml" => "config/secrets.yml",
}

after "deploy:restart", "deploy:restart_procfile_worker"
after "deploy:notify", "deploy:notify:error_tracker"
