set :application, "content-store"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, %w(content_store draft_content_store)

set :run_migrations_by_default, true

load 'defaults'
load 'ruby'

require "whenever/capistrano"
set :whenever_command, "govuk_setenv content-store bundle exec whenever"

after "deploy:symlink", "deploy:create_mongoid_indexes"
