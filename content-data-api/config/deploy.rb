set :application, "content-data-api"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, "backend"

set :run_migrations_by_default, true

load 'defaults'
load 'ruby'
load 'deploy/assets'

load 'govuk_admin_template'

set :rails_env, 'production'

namespace :deploy do
  namespace :content_data_api do
    desc "Restart the default worker"
    task :restart_default_worker do
      run "sudo initctl restart content-data-api-default-worker-procfile-worker || "\
          "sudo initctl start content-data-api-default-worker-procfile-worker"
    end

    desc "Restart the Publishing API consumer"
    task :restart_publishing_api_consumer do
      run "sudo initctl restart content-data-api-publishing-api-consumer-procfile-worker ||"\
          "sudo initctl start content-data-api-publishing-api-consumer-procfile-worker"
    end

    desc "Restart the Publishing API bulk import consumer"
    task :restart_publishing_api_bulk_import_consumer do
      run "sudo initctl restart content-data-api-bulk-import-publishing-api-consumer-procfile-worker ||"\
          "sudo initctl start content-data-api-bulk-import-publishing-api-consumer-procfile-worker"
    end
  end
end

after "deploy:restart", "deploy:content_data_api:restart_default_worker"
after "deploy:restart", "deploy:content_data_api:restart_publishing_api_consumer"
after "deploy:restart", "deploy:content_data_api:restart_publishing_api_bulk_import_consumer"
