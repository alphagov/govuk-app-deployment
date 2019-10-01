set :application, "backdrop-write"
set :repo_name, "backdrop"
set :server_class, "api"
set :capfile_dir, File.expand_path("../", File.dirname(__FILE__))
set :shared_children, shared_children + %w(log)

load "defaults"
load "python"

namespace :deploy do
  task :upload_environment_settings do
    config_folder = File.expand_path("secrets/settings/#{ENV['ORGANISATION']}", Dir.pwd)
    if File.exist?(config_folder)
      %w{write transformers}.each do |app|
        Dir.glob(File.join("#{config_folder}/#{app}", "*.py")).each do |settings|
          top.upload(settings, File.join(release_path, "backdrop/#{app}/config/#{File.basename(settings)}"))
        end
      end
    end
  end

  task :setup_shared_audit_directory do
    audit_dir_path = "#{shared_path}/log/audit"
    run "test -d #{audit_dir_path} || mkdir #{audit_dir_path}"
  end
end

before "deploy:finalize_update", "deploy:upload_environment_settings"
after "deploy:link_shared_children", "deploy:setup_shared_audit_directory"
