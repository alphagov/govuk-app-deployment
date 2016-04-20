set :application, "service-manual-frontend"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, [
  "draft_frontend",
  "frontend",
]

load 'defaults'
load 'ruby'
load 'deploy/assets'

set :assets_prefix, 'service-manual-frontend'
set :rails_env, 'production'

after "deploy:notify", "deploy:notify:errbit"
