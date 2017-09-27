set :application, "local-links-manager"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, "backend"
set :run_migrations_by_default, true

load 'defaults'
load 'ruby'
load 'deploy/assets'
load 'govuk_admin_template'

set :whenever_command, "bundle exec whenever"
require "whenever/capistrano" # This hooks a task to run before deploy:finalize_update

set :copy_exclude, [
 '.git/*',
 'public/**/*'
]

namespace :deploy do
  desc <<-DESC
    Create the data directory for CSV exports.
  DESC
  task :setup_data_directory do
    run <<-EOT
mkdir -p #{shared_path}/data
    EOT
  end

  desc <<-DESC
    Symlink the shared data directory into the new release.
  DESC
  task :symlink_data_directory do
    run <<-EOT
rm -rf #{latest_release}/public/data &&
ln -s #{shared_path}/data #{latest_release}/public/data
    EOT
  end
end

after "deploy:setup", "deploy:setup_data_directory"
after "deploy:finalize_update", "deploy:symlink_data_directory"
