set :application, "contacts"
set :capfile_dir, File.expand_path("../", File.dirname(__FILE__))

set :repo_name, "contacts-admin"

set :run_migrations_by_default, true

load "defaults"
load "ruby"
load "deploy/assets"

load 'govuk_admin_template'

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

after "deploy:symlink", "deploy:publishing_api:publish"
after "deploy:notify", "deploy:notify:errbit"
