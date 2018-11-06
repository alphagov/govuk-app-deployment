set :application, "ckan"
set :server_class, "ckan"
set :capfile_dir, File.expand_path("../", File.dirname(__FILE__))
set :shared_children, shared_children + %w(log)
set :repo_name, 'ckanext-datagovuk'

load "defaults"
load "python"

def run_paster_command(command)
  run "cd #{release_path} && govuk_setenv #{application} #{virtualenv_path}/bin/paster --plugin ckan #{command} -c /var/ckan/ckan.ini"
end

namespace :deploy do
  task :restart, :roles => :app, :max_hosts => 1, :except => { :no_release => true } do
    # Override task from python recipe which invokes 'initctl restart' rather
    # than 'reload' which plays nicely with unicornherder
    run "sudo initctl start #{application} 2>/dev/null || sudo initctl reload #{application};"
  end

  task :migrate, :only => { :primary => true } do
    run_paster_command("db upgrade")
  end

  task :install_deps, roles: :app do
    run "cd #{release_path} && bin/install-dependencies.sh #{virtualenv_path}/bin/pip"
  end

  task :install_package, roles: :app do
    run "cd #{release_path} && '#{virtualenv_path}/bin/python' #{release_path}/setup.py install"
  end
end

after "deploy:create_symlink", "deploy:install_package"
