set :application, "efg-training"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :repo_name, "EFG"
set :server_class, "efg_frontend"

set :whenever_command, "bundle exec whenever"
require "whenever/capistrano"

set :source_db_config_file, 'secrets/to_upload/database.yml'
set :db_config_file, 'config/database.yml'

set :run_migrations_by_default, true

load 'defaults'
load 'ruby'
load 'deploy/assets'

set :rails_env, 'production'

set :copy_exclude, [
  'public/images',
  'public/javascripts',
  'public/stylesheets',
  'public/templates'
]

namespace :deploy do
  task :upload_lender_logos do
    lender_logos_folder = File.expand_path(File.join(Dir.pwd, 'secrets', 'logos'))
    remote_logo_dir = File.join(shared_path, 'system', 'logos')
    if File.exist?(lender_logos_folder)
      run "test -d #{remote_logo_dir} || mkdir -p #{remote_logo_dir}"
      Dir.glob(File.join(lender_logos_folder, "*.jpg")).each do |logo|
        top.upload(logo, File.join(remote_logo_dir, File.basename(logo)))
      end
    end
  end
end

after "deploy:upload_initializers", "deploy:upload_lender_logos"
after "deploy:upload_initializers", "deploy:symlink_mailer_config"
