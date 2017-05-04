set :application, "stagecraft"
set :server_class, "api"
set :capfile_dir, File.expand_path("../", File.dirname(__FILE__))
set :shared_children, shared_children + %w(log)

set :virtualenv_setuptools, true

load "defaults"
load "python"

namespace :deploy do
  task :migrate, :only => { :primary => true } do
    if fetch(:run_migrations_by_default, true)
      run_django_command("migrate --noinput")
    end
  end

  task :static do
    run_django_command("collectstatic --noinput")
  end

  task :upload_environment_settings do
    config_folder = File.expand_path("secrets/settings/#{ENV['ORGANISATION']}", Dir.pwd)
    if File.exist?(config_folder)
      Dir.glob(File.join(config_folder, "*.py")).each do |settings|
        top.upload(settings, File.join(release_path, "stagecraft/settings/#{File.basename(settings)}"))
      end
    end
  end

  task :setup_shared_audit_directory do
    audit_dir_path = "#{shared_path}/log/audit"
    run "test -d #{audit_dir_path} || mkdir #{audit_dir_path}"
  end

  desc "Restart the Celery workers"
  task :restart_procfile_worker do
    run "sudo initctl start stagecraft-worker-procfile-worker 2>/dev/null || sudo initctl restart stagecraft-worker-procfile-worker"
  end

  # we only have celery beat on a single server
  desc "Restart CeleryBeat"
  task :restart_celery_beat do
    process_name = "stagecraft-beat-procfile-worker"
    if File.exist?("/etc/init/#{process_name}.conf")
      run "sudo initctl start #{process_name} 2>/dev/null || sudo initctl restart #{process_name}"
    end
  end

  # we only have celery cam on a single server
  desc "Restart CeleryCam"
  task :restart_celery_cam do
    process_name = "stagecraft-celerycam-procfile-worker"
    if File.exist?("/etc/init/#{process_name}.conf")
      run "sudo initctl start #{process_name} 2>/dev/null || sudo initctl restart #{process_name}"
    end
  end

  def run_django_command(command)
    run "cd #{release_path} && #{shared_path}/venv/bin/python manage.py #{command} --settings=stagecraft.settings.production"
  end
end

before "deploy:install_deps", "deploy:upgrade_pip"
before "deploy:finalize_update", "deploy:upload_environment_settings", "deploy:migrate", "deploy:static"
after "deploy:link_shared_children", "deploy:setup_shared_audit_directory"
after "deploy:restart", "deploy:restart_procfile_worker", "deploy:restart_celery_beat", "deploy:restart_celery_cam"
