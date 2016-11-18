set :application, "short-url-manager"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, "backend"

set :source_db_config_file, 'to_upload/mongoid.yml'
set :db_config_file, 'config/mongoid.yml'

set :config_files_to_upload, {
  "to_upload/redis.yml" => 'config/redis.yml',
  "to_upload/secrets.yml" => "config/secrets.yml",
  "to_upload/schedule.rb" => "config/schedule.rb",
}

set :run_migrations_by_default, true

load "defaults"
load "ruby"
load "deploy/assets"
load 'govuk_admin_template'

set :whenever_command, "bundle exec whenever"
require "whenever/capistrano"

after "deploy:upload_initializers", "deploy:symlink_mailer_config"
after "deploy:symlink", "deploy:create_mongoid_indexes"
after "deploy:notify", "deploy:notify:errbit"
