set :application, "whitehall"
set :capfile_dir, File.expand_path("../", File.dirname(__FILE__))

set :run_migrations_by_default, true

load "defaults"
load "ruby"
load "deploy/assets"
require "config_putter"

load "govuk_admin_template"

set :server_class, {
  "whitehall_frontend" => { roles: %i[frontend web app] },
  "whitehall_backend" => { roles: %i[db backend web app] },
}

set :bundle_without, %i[development test test_coverage cucumber]
require "whenever/capistrano"
set :whenever_command, "govuk_setenv whitehall bundle exec whenever"
set :whenever_roles, [:backend]

set :copy_exclude, [
  ".git/*",
]

logger.level = Logger::MAX_LEVEL

# Force assets:precompile to run with trace, as we've been seeing intermittent errors
namespace :deploy do
  namespace :assets do
    task :precompile, :roles => :web, :except => { :no_release => true } do
      # Force capistrano to close existing ssh connections.  It will then reopen them later when it needs them again
      # Without this, the connections will timeout by the time all the local assets stuff has completed.
      teardown_connections_to(find_servers)

      Bundler.with_clean_env do
        ENV.delete("RUBY_VERSION")
        ENV.delete("RBENV_DIR")
        ENV.delete("RBENV_VERSION")
        ENV.delete("GEM_HOME")
        bundle_locally
        mustache_precompile_locally
        assets_precompile_locally
        rsync_local_assets
      end
    end

    task :bundle_locally, :roles => :web, :except => { :no_release => true } do
      puts run_locally "cd #{strategy.local_cache_path}; govuk_setenv default bundle --path #{ENV['HOME']}/bundles/whitehall-assets --deployment --without development staging test test_coverage cucumber"
    end

    task :assets_precompile_locally, roles => :web, :except => { :no_release => true } do
      puts run_locally "cd #{strategy.local_cache_path}; SKIP_OBSERVERS_FOR_ASSET_TASKS=true govuk_setenv default bundle exec rake assets:precompile --trace"
    end

    task :mustache_precompile_locally, roles => :web, :except => { :no_release => true } do
      puts run_locally "cd #{strategy.local_cache_path}; govuk_setenv default bundle exec rake shared_mustache:compile --trace"
    end

    task :rsync_local_assets, roles => :web, :except => { :no_release => true } do
      find_servers.each do |server|
        puts run_locally "cd #{strategy.local_cache_path} && rsync -aK ./public/assets/ #{user}@#{server}:#{shared_path}/assets/"
      end
    end
  end
end

namespace :deploy do
  task :symlink_uploads, roles: [:backend] do
    run "rm -rf #{latest_release}/carrierwave-tmp && mkdir -p /data/uploads/whitehall/carrierwave-tmp && ln -sfn /data/uploads/whitehall/carrierwave-tmp #{latest_release}/carrierwave-tmp"
    run "ln -sfn /data/uploads/whitehall/clean #{latest_release}/clean-uploads"
    run "ln -sfn /data/uploads/whitehall/incoming #{latest_release}/incoming-uploads"
    run "ln -sfn /data/uploads/whitehall/infected #{latest_release}/infected-uploads"
    run "ln -sfn /data/uploads/whitehall/asset-manager-tmp #{latest_release}/asset-manager-tmp"
    run "mkdir -p /data/uploads/whitehall/attachment-cache && ln -sfn /data/uploads/whitehall/attachment-cache #{latest_release}/attachment-cache"
    run "mkdir -p /data/uploads/whitehall/bulk-upload-zip-file-tmp && ln -sfn /data/uploads/whitehall/bulk-upload-zip-file-tmp #{latest_release}/bulk-upload-zip-file-tmp"
    run "rm -f #{latest_release}/public/government/uploads"
  end

  task :restart do
    restart_frontend
    restart_backend
  end

  task :restart_frontend, roles: [:frontend], except: { no_release: true } do
    if fetch(:perform_hard_restart, false)
      run "sudo initctl start whitehall 2>/dev/null || sudo initctl restart whitehall"
    else
      run "sudo initctl start whitehall 2>/dev/null || sudo initctl reload whitehall"
    end
  end

  task :restart_backend, roles: [:backend], except: { no_release: true } do
    if fetch(:perform_hard_restart, false)
      run "sudo initctl start whitehall 2>/dev/null || sudo initctl restart whitehall"
    else
      run "sudo initctl start whitehall 2>/dev/null || sudo initctl reload whitehall"
    end
  end

  task :restart_workers, roles: [:backend], except: { no_release: true } do
    run "sudo initctl restart whitehall-admin-procfile-worker || sudo initctl start whitehall-admin-procfile-worker"
  end
end

namespace :db do
  desc "Run data migrations"
  task :migrate_data, roles: [:db], only: { :primary => true } do
    rails_env = fetch(:rails_env, "production")
    run "cd #{current_release}; #{rake} RAILS_ENV=#{rails_env} db:data:migrate"
  end
end

after "deploy:finalize_update", "deploy:symlink_uploads"
after "deploy:restart_backend", "deploy:restart_workers"
