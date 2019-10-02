set :application, "asset-manager"
set :capfile_dir, File.expand_path("../", File.dirname(__FILE__))
set :server_class, "backend"

load "defaults"
load "ruby"

load "deploy/assets"
set :assets_prefix, "asset-manager"

set :rails_env, "production"

namespace :deploy do
  desc "Create a symlink from the latest_release path to the /data/uploads directory"
  task :create_uploads_symlink do
    run "mkdir -p /data/uploads/asset-manager && ln -sfn /data/uploads/asset-manager #{latest_release}/uploads"
  end
end

after "deploy:update_code", "deploy:create_uploads_symlink"
after "deploy:restart", "deploy:restart_procfile_worker"
