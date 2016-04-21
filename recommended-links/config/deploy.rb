set :application, "recommended-links"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, "backend"

load 'defaults'
load 'ruby'

# TODO: to be removed once env.d exists for recommended-links
set :rake, "govuk_setenv default bundle exec rake"
set :source_db_config_file, false
set :db_config_file, false

set :config_files_to_upload, {}

set :copy_exclude, [
  '.git/*',
]

namespace :deploy do
  task :restart, :roles => :app, :except => {:no_release => true} do
  end

  namespace :rummager do
    task :index do
      run "cd #{current_release}; #{rake} RAILS_ENV=production deploy_links"
    end
  end
end
after "deploy:finalize_update", "deploy:rummager:index"
