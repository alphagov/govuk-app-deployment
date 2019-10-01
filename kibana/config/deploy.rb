set :application, "kibana"
set :capfile_dir, File.expand_path("../", File.dirname(__FILE__))
set :server_class, "backend"
set :repo_name, "kibana-gds"

load "defaults"
load "ruby"
