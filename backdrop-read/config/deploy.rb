set :application, "backdrop-read"
set :repo_name, "backdrop"
set :server_class, "api"
set :capfile_dir, File.expand_path("../", File.dirname(__FILE__))
set :shared_children, shared_children + %w[log]

load "defaults"
load "python"

namespace :deploy do
  task :upload_environment_settings do
    config_folder = File.expand_path("secrets/settings/#{ENV['ORGANISATION']}", Dir.pwd)
    if File.exist?(config_folder)
      Dir.glob(File.join(config_folder, "*.py")).each do |settings|
        top.upload(settings, File.join(release_path, "backdrop/read/config/#{File.basename(settings)}"))
      end
    end
  end
end

before "deploy:finalize_update", "deploy:upload_environment_settings"
