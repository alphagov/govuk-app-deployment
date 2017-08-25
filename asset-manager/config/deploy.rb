set :application, "asset-manager"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, "backend"

load 'defaults'
load 'ruby'

set :rails_env, 'production'

namespace :deploy do
  desc "Create a symlink from the latest_release path to the /data/uploads directory"
  task :create_uploads_symlink do
    run "mkdir -p /data/uploads/asset-manager && ln -sfn /data/uploads/asset-manager #{latest_release}/uploads"
  end

  desc "Restart the delayed_job worker"
  task :restart_delayed_job do
    run "sudo initctl start asset-manager-delayed-job-worker || sudo initctl restart asset-manager-delayed-job-worker"
  end
end

after "deploy:update_code", "deploy:create_uploads_symlink"
after "deploy:restart", "deploy:restart_delayed_job"
after "deploy:notify", "deploy:notify:error_tracker"
