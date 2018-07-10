set :application, "content-publisher"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, "backend"

load 'defaults'
load 'ruby'
load 'deploy/assets'

set :copy_exclude, [
  '.git/*'
]

after "deploy:restart"
