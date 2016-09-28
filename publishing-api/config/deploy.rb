set :application, "publishing-api"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, "backend"

set :run_migrations_by_default, true

load 'defaults'
load 'ruby'

after "deploy:restart", "deploy:restart_procfile_worker"
after "deploy:notify", "deploy:notify:errbit"
after "deploy:finalize_update", "deploy:symlink_schemas"

namespace :deploy do
  task :symlink_schemas do
    run "ln -sfn /data/apps/publishing-api/shared/govuk-content-schemas #{latest_release}/govuk-content-schemas"
  end
end
