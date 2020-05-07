set :application, "frontend"
set :capfile_dir, File.expand_path("../", File.dirname(__FILE__))
set :server_class, %w[draft_frontend frontend]

set :source_db_config_file, false
set :db_config_file, false

load "defaults"
load "ruby"
load "deploy/assets"

set :assets_prefix, "frontend"
set :copy_exclude, [
  ".git/*",
  "public/images",
  "public/javascripts",
  "public/stylesheets",
  "public/templates",
]

after "deploy:restart", "deploy:restart_procfile_worker"
