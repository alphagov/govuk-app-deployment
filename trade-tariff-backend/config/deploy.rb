set :application, "tariff-api"
set :capfile_dir, File.expand_path("../", File.dirname(__FILE__))
set :server_class, "backend"
set :repo_name, "trade-tariff-backend"

set :source_db_config_file, 'secrets/to_upload/database.yml'

set :db_config_file, "config/database.yml"

set :run_migrations_by_default, true

load "defaults"
load "ruby"
load "deploy/assets"

set :rails_env, "production"

set :bundle_without, [:development, :test, :webkit]

set :whenever_command, "bundle exec whenever"
require "whenever/capistrano"

# This requires an older version of capistrano than the one we're currently on.
# https://github.com/capistrano/capistrano/commit/44e96a4a8b69bd7b8ecf8ad384f12a46a7f3e0df
#set :shared_children, shared_children + %w{data}

set :copy_exclude, [
  ".git/*",
  "public/images",
  "public/javascripts",
  "public/stylesheets",
  "public/templates"
]

set :config_files_to_upload, {
  "secrets/to_upload/trade_tariff_backend_secrets.yml" => "config/trade_tariff_backend_secrets.yml"
}

# cf above comment - we write inline stuff to do what we want instead.
namespace :deploy do
  desc <<-DESC
    Create the data directories that we need.
  DESC
  task :setup_data_directories do
    run <<-EOT
mkdir -p #{shared_path}/data/taric &&
mkdir -p #{shared_path}/data/chief
    EOT
  end

  desc <<-DESC
    Symlink the shared data directories into the new release.
  DESC
  task :symlink_data_directories do
    run <<-EOT
rm -rf #{latest_release}/data &&
ln -s #{shared_path}/data #{latest_release}/data
    EOT
  end
end

after "deploy:setup", "deploy:setup_data_directories"
after "deploy:finalize_update", "deploy:symlink_data_directories"
after "deploy:restart", "deploy:restart_procfile_worker"
after "deploy:upload_initializers", "deploy:symlink_mailer_config"
after "deploy:notify", "deploy:notify:errbit"
