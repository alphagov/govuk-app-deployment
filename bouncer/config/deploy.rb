set :application, "bouncer"
set :capfile_dir, File.expand_path("../", File.dirname(__FILE__))
set :server_class, "bouncer"

load "defaults"
load "ruby"

set :source_db_config_file, false
set :db_config_file, false

set :copy_exclude, [
  ".git/*",
  "public",
]

set :legacy_asset_repositories, %w[assets-directgov assets-businesslink]

namespace :deploy do
  task :sync_legacy_assets do
    git_origin_prefix = ENV["DEPLOY_FROM_GITLAB"] == "true" ? "git@gitlab.com:govuk" : "git@github.com:alphagov"

    legacy_asset_repositories.each do |repository|
      # Cache the checkout to avoid redownloading large repos on each deploy
      local_directory = "#{ENV['HOME']}/rsync-cache/#{repository}"

      # Specify --depth 1 to avoid cloning the entire history of the repo, which
      # will include files which have been removed when we just need the current
      # state.
      remote_url = "#{git_origin_prefix}/#{repository}.git"
      puts run_locally "if cd #{local_directory}; then git remote set-url origin #{remote_url}; git fetch origin; git reset --hard origin/master; else git clone --depth 1 #{remote_url} #{local_directory}; fi"

      find_servers.each do |server|
        # Update the existing files to the server in, for example:
        # /data/vhost/bouncer.preview.alphagov.co.uk/shared/assets-directgov
        puts run_locally "rsync --delete -avz --exclude '.git/' -e ssh #{local_directory} #{user}@#{server}:#{shared_path}"

        # Symlink the directory we've just synced to, for example:
        # /var/app/bouncer/assets-directgov
        puts run "ln -sfn #{shared_path}/#{repository} #{latest_release}/#{repository}"
      end
    end
  end
end
after "deploy:symlink", "deploy:sync_legacy_assets"
