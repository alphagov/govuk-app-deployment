set :application, "tariff-admin"
set :assets_prefix, "tariff-admin"
set :capfile_dir, File.expand_path("../", File.dirname(__FILE__))
set :server_class, "backend"
set :repo_name, "trade-tariff-admin"

set :source_db_config_file, 'secrets/to_upload/database.yml'

set :db_config_file, "config/database.yml"

load "defaults"
load "ruby"
load "deploy/assets"

set :rails_env, "production"

set :bundle_without, [:development, :test, :webkit]

set :copy_exclude, [
  ".git/*",
  "public/images",
  "public/javascripts",
  "public/stylesheets",
  "public/templates"
]
after "deploy:upload_initializers", "deploy:symlink_mailer_config"
after "deploy:notify", "deploy:notify:errbit"
