set :application, "static"
set :app_port, "3013"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, "docker_manager_frontend"

load 'swarm'
