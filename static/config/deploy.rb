set :application, "static"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, %w(draft_frontend frontend)

load 'defaults'
load 'ruby'
load 'deploy/assets'

set :assets_prefix, 'static'
set :rails_env, 'production'
set :source_db_config_file, false
set :db_config_file, false

namespace :deploy do
  task :cold do
    puts "There's no cold task for this project, just deploy normally"
  end
end
