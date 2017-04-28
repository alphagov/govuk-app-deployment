set :application, "release"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, "docker-backend"

load 'defaults'

after "deploy:notify", "deploy:notify:errbit"
