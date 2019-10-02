set :application, "maslow"

set :capfile_dir, File.expand_path("../", File.dirname(__FILE__))
set :server_class, "backend"

load "defaults"
load "ruby"
load "deploy/assets"

load "govuk_admin_template"

set :rails_env, "production"

set :source_db_config_file, "secrets/to_upload/mongoid.yml"
set :db_config_file, "config/mongoid.yml"
