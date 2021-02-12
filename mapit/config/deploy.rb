set :application, "mapit"
set :server_class, "mapit"
set :capfile_dir, File.expand_path("../", File.dirname(__FILE__))
set :shared_children, shared_children + %w[log]

set :virtualenv_name, "venv3"
set :virtualenv_python_binary, "python3.6"

load "defaults"
load "python"

namespace :deploy do
  task :migrate, :only => { :primary => true } do
    run_django_command("migrate --noinput")
  end

  task :install_deps, :roles => :app do
    # Override task from python recipe, which appends '-e .' to requirements.txt
    # However, '.' only works if `pip` is run from `release_path`, which its not
    run "'#{virtualenv_path}/bin/pip' install --download-cache '#{shared_path}/download-cache' --exists-action=w -r '#{release_path}/requirements.txt'"
  end

  task :upload_configuration do
    config_folder = File.expand_path("secrets/settings/#{ENV['ORGANISATION']}", Dir.pwd)
    if File.exist?(config_folder)
      Dir.glob(File.join(config_folder, "*.yml")).each do |settings|
        top.upload(settings, File.join(release_path, "conf/#{File.basename(settings)}"))
      end
    end
  end

  def run_django_command(command)
    run "cd #{release_path} && govuk_setenv #{application} #{virtualenv_path}/bin/python manage.py #{command} --settings=project.settings"
  end
end

before "deploy:finalize_update", "deploy:upload_configuration"
