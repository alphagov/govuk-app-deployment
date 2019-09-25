set :application, "search-api"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, "search"

load 'defaults'
load 'ruby'

set :whenever_command, "govuk_setenv search-api bundle exec whenever"
require "whenever/capistrano"

set :source_db_config_file, false
set :db_config_file, false

set :copy_exclude, [
  '.git/*',
  'public',
]

namespace :deploy do
  task :migrate, :roles => :db, :only => { :primary => true } do
    run "cd #{current_release}; #{rake} RACK_ENV=#{rack_env} RUMMAGER_INDEX=all rummager:migrate_schema rummager:clean"
  end

  desc "Teardown SSH connections to force Capistrano to reopen them in case they have timed out"
  task :teardown_connections do
    teardown_connections_to(find_servers)
  end

  desc "Restart search-api's publishing-api listener for link updates"
  task :restart_publishing_api_listener do
    run "sudo initctl restart search-api-publishing-queue-listener-procfile-worker || sudo initctl start search-api-publishing-queue-listener-procfile-worker"
  end

  desc "Restart search-api's publishing-api listener for govuk-index"
  task :restart_published_content_listener do
    run "sudo initctl restart search-api-govuk-index-queue-listener-procfile-worker || sudo initctl start search-api-govuk-index-queue-listener-procfile-worker"
  end

  desc "Restart search-api's publishing-api bulk reindex listener for govuk-index"
  task :restart_published_content_bulk_reindex_listener do
    run "sudo initctl restart search-api-bulk-reindex-queue-listener-procfile-worker || sudo initctl start search-api-bulk-reindex-queue-listener-procfile-worker"
  end
end

after "deploy:restart", "deploy:restart_procfile_worker"
after "deploy:restart", "deploy:restart_publishing_api_listener"
after "deploy:restart", "deploy:restart_published_content_listener"
after "deploy:restart", "deploy:restart_published_content_bulk_reindex_listener"
after "deploy:migrate", "deploy:teardown_connections"
