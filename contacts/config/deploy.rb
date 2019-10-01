set :application, "contacts"
set :capfile_dir, File.expand_path("../", File.dirname(__FILE__))
set :server_class, "backend"

set :repo_name, "contacts-admin"

set :run_migrations_by_default, true

load "defaults"
load "ruby"
load "deploy/assets"

load 'govuk_admin_template'

set :assets_prefix, 'contacts-assets'

require "whenever/capistrano"
set :whenever_command, "bundle exec whenever"
set :whenever_roles, [:backend]

set :copy_exclude, [
  ".git/*",
  "public/images",
  "public/javascripts",
  "public/stylesheets",
  "public/templates",
]
