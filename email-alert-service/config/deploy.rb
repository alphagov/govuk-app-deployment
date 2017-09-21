set :application, "email-alert-service"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, "backend"

load 'defaults'
load 'ruby'

set :copy_exclude, [
  '.git/*',
]

after "deploy:notify", "deploy:notify:error_tracker"
