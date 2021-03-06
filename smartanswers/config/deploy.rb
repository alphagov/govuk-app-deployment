set :application,        "smartanswers"
set :capfile_dir,        File.expand_path("../", File.dirname(__FILE__))
set :server_class,       %w[draft_frontend calculators_frontend]
set :repo_name,          "smart-answers"

load "defaults"
load "ruby"
load "deploy/assets"

set :bundle_without, %i[development test webkit]
set :db_config_file, false
set :rails_env, "production"
set :source_db_config_file, false

namespace :deploy do
  task :cold do
    puts "There's no cold task for this project, just deploy normally"
  end
end
