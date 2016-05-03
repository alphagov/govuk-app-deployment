set :application, "transition"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, "backend"

load 'defaults'
load 'ruby'
load 'deploy/assets'

load 'govuk_admin_template'

set :source_db_config_file, 'secrets/to_upload/database.yml'

set :config_files_to_upload, {
    "secrets/to_upload/redis.yml" => 'config/redis.yml',
}

set :whenever_command, "bundle exec whenever"
require "whenever/capistrano" # This hooks a task to run before deploy:finalize_update

set :copy_exclude, [
  '.git/*',
  'public/images',
  'public/javascripts',
  'public/stylesheets',
  'public/templates'
]

namespace :deploy do
  task :symlink_data_dir do
    run <<-EOT
      rm -rf #{latest_release}/data &&
      mkdir -p #{shared_path}/app_data &&
      ln -s #{shared_path}/app_data #{latest_release}/data
    EOT
  end
end

after "deploy:finalize_update", "deploy:symlink_data_dir"
after "deploy:upload_initializers", "deploy:symlink_mailer_config"
after "deploy:restart", "deploy:restart_procfile_worker"
after "deploy:notify", "deploy:notify:errbit"
