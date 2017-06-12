set :application, "contentapi"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, "backend"
set :repo_name, "govuk_content_api"

load 'defaults'
load 'ruby'

set :copy_exclude, [
  '.git/*',
  'public/images',
  'public/javascripts',
  'public/stylesheets',
  'public/templates'
]

after "deploy:notify", "deploy:notify:errbit"
