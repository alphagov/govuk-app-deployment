set :application, "licencefinder"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, "calculators_frontend"
set :repo_name, "licence-finder"

load 'defaults'
load 'ruby'
load 'deploy/assets'

set :assets_prefix, "licencefinder"
set :rails_env, 'production'
set :bundle_without, [:development, :test, :webkit]

set :copy_exclude, [
  '.git/*',
  'public/images',
  'public/javascripts',
  'public/stylesheets',
  'public/templates'
]

after "deploy:upload_initializers", "deploy:symlink_mailer_config"
after "deploy:symlink", "deploy:panopticon:register"
after "deploy:symlink", "deploy:rummager:index"
after "deploy:symlink", "deploy:publishing_api:publish"
