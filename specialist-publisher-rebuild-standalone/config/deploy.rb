set :application, "specialist-publisher-rebuild-standalone"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, "backend"
set :repo_name, "specialist-publisher-rebuild"

load 'defaults'
load 'ruby'
load 'deploy/assets'
load 'govuk_admin_template'

after "deploy:notify", "deploy:notify:errbit"
