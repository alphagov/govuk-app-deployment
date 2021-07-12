set :application, "specialist-publisher"
set :capfile_dir, File.expand_path("../", File.dirname(__FILE__))
set :server_class, "backend"

load "defaults"
load "ruby"
load "deploy/assets"

after "deploy:restart", "deploy:restart_procfile_worker"
