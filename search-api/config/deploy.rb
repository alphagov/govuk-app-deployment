# rubocop:disable Metrics/BlockLength, Naming/HeredocDelimiterNaming

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
  task :create_sitemaps do
    # Preserve the directory containing sitemap files between releases
    run <<-EOT
      rm -rf #{latest_release}/public/sitemaps &&
      mkdir -p #{shared_path}/system/sitemaps &&
      ln -s #{shared_path}/system/sitemaps #{latest_release}/public/sitemaps
    EOT

    # Preserve the generated sitemap.xml symlink from the previous release if present.
    #
    # This de-references the symlink to ensure that it's pointing directly into the shared dir.
    # Otherwise there's a risk of the previous release being cleaned up and this becoming a
    # dangling symlink
    run <<-EOT
      test -L #{previous_release}/public/sitemap.xml || exit 0;
      ln -s `readlink -nf #{previous_release}/public/sitemap.xml` #{latest_release}/public/sitemap.xml
    EOT

    # Generate the sitemap files if they don't exist.
    run <<-EOT
      test -L #{latest_release}/public/sitemap.xml && exit 0;
      echo "First deploy of search-api to this node, generating sitemap files..."
      cd #{latest_release}
      govuk_setenv search-api bundle exec rake sitemap:generate_and_replace
    EOT
  end

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

after "deploy:finalize_update", "deploy:create_sitemaps"
after "deploy:restart", "deploy:restart_procfile_worker"
after "deploy:restart", "deploy:restart_publishing_api_listener"
after "deploy:restart", "deploy:restart_published_content_listener"
after "deploy:restart", "deploy:restart_published_content_bulk_reindex_listener"
after "deploy:migrate", "deploy:teardown_connections"
