set :application, 'sidekiq-monitoring'
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, 'backend'

load 'defaults'
load 'ruby'
