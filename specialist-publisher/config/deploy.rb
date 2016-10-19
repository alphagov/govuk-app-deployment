set :application, "specialist-publisher"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, "backend"

load 'defaults'
load 'ruby'
load 'deploy/assets'
load 'govuk_admin_template'


# FIXME This is a temporary measure to prevent initializers from the original
# Specialist Publisher application being deployed into the Specialist Publisher
# Rebuild application. This can be safely removed once the initializers have
# been removed from the old deployment repo.
["deploy:upload_config", "deploy:upload_initializers"].each do |callback_source|
  callback = callbacks[:after].find { |c| c.source == callback_source }
  callbacks[:after].delete(callback)
end

after "deploy:restart", "deploy:restart_procfile_worker"
after "deploy:notify", "deploy:notify:errbit"
