# Use rbenv shims if available
set :default_environment, {
  "RBENV_ROOT" => "/usr/lib/rbenv",
  "PATH" => "/usr/lib/rbenv/shims:$PATH",
}

set(:source_db_config_file, "secrets/to_upload/database.yml") unless fetch(:source_db_config_file, false)
set(:db_config_file, "config/database.yml") unless fetch(:db_config_file, false)
set(:rack_env,  :production)
set(:rails_env, :production)
set(:rake, "govuk_setenv #{fetch(:application)} bundle exec rake ASSET_HOST=\"\"")

namespace :deploy do
  task :start do; end
  task :stop do; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    # The deploy user always has permission to run initctl commands.
    if fetch(:perform_hard_restart, false)
      # hard-restart is a non-graceful restart of the app.  This has the advantage
      # of being immediate, and blocking.  Used by some of the post data-syncing
      # scripts
      run "sudo govuk_supervised_initctl start #{application} || sudo govuk_supervised_initctl restart #{application}"
    else
      run "sudo govuk_supervised_initctl start #{application} || sudo govuk_supervised_initctl reload #{application}"
    end
  end

  desc "A non-graceful restart of the app. Useful for changing ruby version"
  task :hard_restart do
    set(:perform_hard_restart, true)
    restart
  end

  desc "Performs a bundle clean to remove used gems"
  task :clean_old_dependencies do
    command = "if [ -d #{current_path} ]; then "\
                "cd #{current_path}; "\
                "if bundle check; then bundle clean; fi "\
              "fi"

    run(command) unless current_path.nil? || current_path.empty?
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

  task :create_mongoid_indexes, :only => { :primary => true } do
    run "cd #{current_release}; #{rake} db:mongoid:create_indexes"
  end

  task :seed_db, :only => { :primary => true } do
    rails_env = fetch(:rails_env, "production")
    run "cd #{current_release}; #{rake} RAILS_ENV=#{rails_env} db:seed"
  end

  # This is a simplified port of the deprecated bundler/capistrano task in
  # https://github.com/rubygems/rubygems/blob/2af2520b4a7ab1c6eb1fdc3d2ef4d8c062d96ad7/bundler/lib/bundler/capistrano.rb
  # it has been updated to fix deprecations from Bundle 2.1 and up
  task :bundle_install, :roles => :app, :except => { :no_release => true } do
    # Maintain backwards compatibility with: https://github.com/rubygems/rubygems/blob/3b1122701bc15e1ce3bd145b6632a09086842e32/bundler/lib/bundler/deployment.rb#L52
    bundle_without = [*fetch(:bundle_without, %i[development test])].compact
    run "cd #{latest_release}; bundle config set --local without #{bundle_without.join(' ')}"
    run "cd #{latest_release}; bundle config set --local path #{shared_path}/bundle"
    run "cd #{latest_release}; bundle config set --local deployment true"
    run "cd #{latest_release}; bundle install --quiet"
  end
end

before "deploy:update_code", "deploy:clean_old_dependencies"
before "deploy:finalize_update", "deploy:bundle_install"
after "deploy:update_code", "deploy:notify_ruby_version"
after "deploy:finalize_update", "deploy:upload_initializers"
after "deploy:upload_config", "deploy:upload_organisation_config"
after "deploy:upload_initializers", "deploy:upload_organisation_initializers"
after "deploy:notify", "deploy:notify:github", "deploy:notify:docker"
