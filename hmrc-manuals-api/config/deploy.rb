set :application, "hmrc-manuals-api"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, "backend"

load 'defaults'
load 'ruby'

after "deploy:restart", "deploy:restart_procfile_worker"
after "deploy:notify", "deploy:notify:error_tracker"
