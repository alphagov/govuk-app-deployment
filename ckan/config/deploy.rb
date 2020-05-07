set :application, "ckan"
set :server_class, "ckan"
set :capfile_dir, File.expand_path("../", File.dirname(__FILE__))
set :shared_children, shared_children + %w[log]
set :repo_name, "ckanext-datagovuk"

load "defaults"
load "python"

def run_paster_command(command)
  run "cd #{release_path} && govuk_setenv #{application} #{virtualenv_path}/bin/paster --plugin ckan #{command} -c /var/ckan/ckan.ini"
end

namespace :deploy do
  task :migrate, :only => { :primary => true } do
    run_paster_command("db upgrade")
  end

  task :install_deps, roles: :app do
    run "cd #{release_path} && bin/install-dependencies.sh #{virtualenv_path}/bin/pip"
  end

  task :install_package, roles: :app do
    run "cd #{release_path} && '#{virtualenv_path}/bin/python' #{release_path}/setup.py install"
  end

  desc "Restart harvest gather process"
  task :restart_harvest_gather_process do
    run "sudo initctl restart harvester_gather_consumer-procfile-worker || sudo initctl start harvester_gather_consumer-procfile-worker"
  end

  desc "Restart harvest fetch process"
  task :restart_harvest_fetch_process do
    run "sudo initctl restart harvester_fetch_consumer-procfile-worker || sudo initctl start harvester_fetch_consumer-procfile-worker"
  end

  desc "Restart pycsw web process"
  task :restart_pycsw_web_process do
    run "sudo initctl restart pycsw_web-procfile-worker || sudo initctl start pycsw_web-procfile-worker"
  end
end

after "deploy:create_symlink", "deploy:install_package"
after "deploy:restart", "deploy:restart_harvest_gather_process"
after "deploy:restart", "deploy:restart_harvest_fetch_process"
after "deploy:restart", "deploy:restart_pycsw_web_process"
