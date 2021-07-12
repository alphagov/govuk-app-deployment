set :application, "imminence"
set :capfile_dir, File.expand_path("../", File.dirname(__FILE__))
set :server_class, "backend"

set :run_migrations_by_default, false

load "defaults"
load "ruby"
load "deploy/assets"

set :copy_exclude, [
  ".git/*",
  "public/images",
  "public/javascripts",
  "public/stylesheets",
  "public/templates",
]

after "deploy:symlink", "deploy:seed_db"
after "deploy:restart", "deploy:restart_procfile_worker"
