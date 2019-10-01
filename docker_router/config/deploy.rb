set :application, "router"
set :capfile_dir, File.expand_path("../", File.dirname(__FILE__))
set :server_class, %w(cache draft_cache)

load "docker"
