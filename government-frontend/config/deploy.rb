set :application, "government-frontend"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, %w(draft_frontend frontend)

load 'defaults'
load 'ruby'
load 'deploy/assets'

set :assets_prefix, 'government-frontend'
set :rails_env, 'production'

after "deploy:notify", "deploy:notify:error_tracker"
