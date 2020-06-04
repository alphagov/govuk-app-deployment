set :application, "email-alert-frontend"
set :capfile_dir, File.expand_path("../", File.dirname(__FILE__))
set :server_class, %w[draft_frontend frontend]

load "defaults"
load "ruby"
load "deploy/assets"

set :source_db_config_file, false
set :db_config_file, false

set :copy_exclude, [
  ".git/*",
]
