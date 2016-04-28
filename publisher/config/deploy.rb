set :application, "publisher"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, "backend"

set :run_migrations_by_default, true

load 'defaults'
load 'ruby'
load 'deploy/assets'

load 'govuk_admin_template'

set :copy_exclude, [
  '.git/*',
  'public/images',
  'public/javascripts',
  'public/stylesheets',
  'public/templates'
]

# cronjobs should be disabled in the staging organisation, to prevent it collecting
# production fact-check emails for example.
if ENV['ORGANISATION'] == 'production' or ENV['ORGANISATION'] == 'integration'
  set :whenever_command, "bundle exec whenever"
  require "whenever/capistrano"
end

set :config_files_to_upload, {
  "secrets/to_upload/redis.yml" => 'config/redis.yml',
}

namespace :deploy do
  desc "Create a symlink from the latest_release path to the /data/uploads directory"
  task :create_reports_symlink do
    run "rm -rf #{latest_release}/reports && ln -s /data/uploads/publisher/reports #{latest_release}/reports"
  end
end

after "deploy:update_code", "deploy:create_reports_symlink"
after "deploy:upload_initializers", "deploy:symlink_mailer_config"
after "deploy:migrate", "deploy:create_mongoid_indexes"
after "deploy:migrate", "deploy:seed_db"
after "deploy:restart", "deploy:restart_procfile_worker"
after "deploy:notify", "deploy:notify:errbit"
