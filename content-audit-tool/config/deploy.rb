set :application, "content-audit-tool"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, "backend"

set :run_migrations_by_default, true

load 'defaults'
load 'ruby'
load 'deploy/assets'

load 'govuk_admin_template'

set :rails_env, 'production'

namespace :deploy do
  namespace :content_audit_tool do
    desc "Restart the Google Analytics worker"
    task :restart_google_analytics_worker do
      run "sudo initctl restart content-audit-tool-google-analytics-worker-procfile-worker || "\
          "sudo initctl start content-audit-tool-google-analytics-worker-procfile-worker"
    end

    desc "Restart the Publishing API worker"
    task :restart_publishing_api_worker do
      run "sudo initctl restart content-audit-tool-publishing-api-worker-procfile-worker || "\
          "sudo initctl start content-audit-tool-publishing-api-worker-procfile-worker"
    end
  end
end

after "deploy:restart", "deploy:content_audit_tool:restart_google_analytics_worker"
after "deploy:restart", "deploy:content_audit_tool:restart_publishing_api_worker"
