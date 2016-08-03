set :application, "performanceplatform-admin"
set :repo_name, "performanceplatform-admin"
set :server_class, "performance_backend"
set :capfile_dir, File.expand_path("../", File.dirname(__FILE__))
set :shared_children, shared_children + %w(log)

load "defaults"
load "python"

namespace :deploy do
  task :compile_scss do
    run_python_command('tools/compile_sass.py')
  end

  task :upload_environment_settings do
    config_folder = File.expand_path("secrets/settings/#{ENV['ORGANISATION']}", Dir.pwd)
    if File.exist?(config_folder)
      Dir.glob(File.join(config_folder, "*.py")).each do |settings|
        top.upload(settings, File.join(release_path, "application/config/#{File.basename(settings)}"))
      end
    end
  end

  def run_python_command(command)
    run "cd #{release_path} && #{shared_path}/venv/bin/python #{command}"
  end
end

before "deploy:install_deps", "deploy:upgrade_pip"
before "deploy:finalize_update", "deploy:upload_environment_settings", "deploy:compile_scss"
