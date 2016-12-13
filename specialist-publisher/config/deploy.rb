set :application, "specialist-publisher"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, "backend"

load 'defaults'
load 'ruby'
load 'deploy/assets'
load 'govuk_admin_template'

namespace :deploy do
  desc "Publish all Finders to the Publishing API"
  task :publish_finders do
    run "cd #{current_release}; #{rake} publishing_api:publish_finders"
  end
end

after "deploy:setup", "deploy:publish_finders"
after "deploy:restart", "deploy:restart_procfile_worker"
after "deploy:notify", "deploy:notify:errbit"
