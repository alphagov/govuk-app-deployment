set :application, "account-api"
set :capfile_dir, File.expand_path("../", File.dirname(__FILE__))
set :server_class, "account"
set :repository, "git@github.com/alphagov/account-api.git"

set :run_migrations_by_default, true

load "defaults"
load "ruby"

set :copy_exclude, [
  ".git/*",
]

after "deploy:restart", "deploy:restart_procfile_worker"
