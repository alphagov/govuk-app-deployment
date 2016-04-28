set :application, "content-store"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, [
  "content_store",
  "draft_content_store",
]

set :run_migrations_by_default, true

load 'defaults'
load 'ruby'

set :config_files_to_upload, {
  "secrets/to_upload/rabbitmq.yml.erb" => "config/rabbitmq.yml",
  "secrets/to_upload/unicorn.rb" => "config/unicorn.rb",
}

require "whenever/capistrano"
set :whenever_command, "govuk_setenv content-store bundle exec whenever"

after "deploy:symlink", "deploy:create_mongoid_indexes"
after "deploy:notify", "deploy:notify:errbit"
