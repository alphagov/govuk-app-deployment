set :application, "content-data-admin"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, "backend"
set :repository, "git@github.com/alphagov/content-data-admin.git"
set :run_migrations_by_default, true

load 'defaults'
load 'ruby'
load 'deploy/assets'

set :copy_exclude, [
  '.git/*'
]
