set :application, "contacts"
set :capfile_dir, File.expand_path("../", File.dirname(__FILE__))

set :source_db_config_file, "secrets/to_upload/database.yml"
set :db_config_file, "config/database.yml"
set :repo_name, "contacts-admin"

set :run_migrations_by_default, true

load "defaults"
load "ruby"
load "deploy/assets"

load 'govuk_admin_template'

require 'config_putter'

set :assets_prefix, 'contacts-assets'

set :server_class, {
  frontend: { roles: [:frontend, :web, :app] },
  backend: { roles: [:backend, :db, :web, :app] },
}

require "whenever/capistrano"
set :whenever_command, "bundle exec whenever"
set :whenever_roles, [:backend]

set :copy_exclude, [
  ".git/*",
  "public/images",
  "public/javascripts",
  "public/stylesheets",
  "public/templates"
]

namespace :deploy do
  task :upload_admin_config, roles: [:backend] do
    config_source = File.expand_path("secrets/admin_to_upload/config", Dir.pwd)
    remote_destination = File.join(release_path, "config")
    ConfigPutter.new(self).put_all(config_source, remote_destination)
  end

  task :upload_admin_initializers, roles: [:backend] do
    config_folder = File.expand_path("secrets/admin_to_upload/initializers/#{rails_env}", Dir.pwd)
    Dir.glob(File.join(config_folder, "*.rb")).each do |initializer|
      top.upload(initializer, File.join(release_path, "config/initializers/#{File.basename(initializer)}"))
    end
  end
end

after "deploy:upload_config", "deploy:upload_admin_config"
after "deploy:upload_initializers", "deploy:upload_admin_initializers"
after "deploy:symlink", "deploy:publishing_api:publish_special_routes"
after "deploy:notify", "deploy:notify:errbit"
