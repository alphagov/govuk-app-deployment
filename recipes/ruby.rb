require "bundler/capistrano"

# Use rbenv shims if available
set :default_environment, {
  "RBENV_ROOT" => "/usr/lib/rbenv",
  "PATH" => "/usr/lib/rbenv/shims:$PATH",
}

set :bundle_cmd, "bundle"
set(:source_db_config_file, "secrets/to_upload/database.yml") unless fetch(:source_db_config_file, false)
set(:db_config_file, "config/database.yml") unless fetch(:db_config_file, false)
set(:rack_env,  :production)
set(:rails_env, :production)
set(:rake, "govuk_setenv #{fetch(:application)} #{fetch(:rake, 'bundle exec rake')}")

namespace :deploy do
  task :start do; end
  task :stop do; end
  task :restart, :roles => :app, :max_hosts => 1, :except => { :no_release => true } do
    # The deploy user always has permission to run initctl commands.
    if fetch(:perform_hard_restart, false)
      # hard-restart is a non-graceful restart of the app.  This has the advantage
      # of being immediate, and blocking.  Used by some of the post data-syncing
      # scripts
      run "sudo initctl start #{application} 2>/dev/null || sudo initctl restart #{application}"
    else
      run "sudo initctl start #{application} 2>/dev/null || sudo initctl reload #{application}"
    end
  end

  desc "A non-graceful restart of the app. Useful for changing ruby version"
  task :hard_restart do
    set(:perform_hard_restart, true)
    restart
  end

  desc "Performs a bundle clean to remove used gems"
  task :clean_old_dependencies do
    run "cd #{current_path} && #{bundle_cmd} clean" unless current_path.nil? || current_path.empty?
  end

  task :notify_ruby_version do
    run "cd #{latest_release} && ruby -v"
  end

  task :upload_initializers do
    config_folder = File.expand_path("secrets/to_upload/initializers/#{rails_env}", Dir.pwd)
    if File.exist?(config_folder)
      Dir.glob(File.join(config_folder, "*.rb")).each do |initializer|
        top.upload(initializer, File.join(release_path, "config/initializers/#{File.basename(initializer)}"))
      end
    end
  end

  task :upload_organisation_initializers do
    config_folder = File.expand_path("secrets/initializers_by_organisation/#{ENV['ORGANISATION']}", Dir.pwd)
    if File.exist?(config_folder)
      Dir.glob(File.join(config_folder, "*.rb")).each do |initializer|
        top.upload(initializer, File.join(release_path, "config/initializers/#{File.basename(initializer)}"))
      end
    end
  end

  task :upload_organisation_config do
    config_folder = File.expand_path("secrets/to_upload/config/#{ENV['ORGANISATION']}", Dir.pwd)
    if File.exist?(config_folder)
      Dir.glob(File.join(config_folder, "*.{rb,yml,json,p12}")).each do |config_file|
        top.upload(config_file, File.join(release_path, "config/#{File.basename(config_file)}"))
      end
    end
  end

  task :symlink_mailer_config do
    run "ln -sf /etc/govuk/actionmailer_ses_smtp_config.rb #{release_path}/config/initializers/mailer.rb"
  end

  task :create_mongoid_indexes, :only => { :primary => true } do
    run "cd #{current_release}; #{rake} db:mongoid:create_indexes"
  end

  task :seed_db, :only => { :primary => true } do
    rails_env = fetch(:rails_env, "production")
    run "cd #{current_release}; #{rake} RAILS_ENV=#{rails_env} db:seed"
  end
end

before "deploy:update_code", "deploy:clean_old_dependencies"
after "deploy:update_code", "deploy:notify_ruby_version"
after "deploy:finalize_update", "deploy:upload_initializers"
after "deploy:upload_config", "deploy:upload_organisation_config"
after "deploy:upload_initializers", "deploy:upload_organisation_initializers"
after "deploy:notify", "deploy:notify:github", "deploy:notify:docker"
