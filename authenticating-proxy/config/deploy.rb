set :application, "authenticating-proxy"
set :capfile_dir, File.expand_path("../", File.dirname(__FILE__))
set :server_class, %w[
  draft_cache
]

set :run_migrations_by_default, true

load "defaults"
load "ruby"

set :rails_env, "production"

namespace :deploy do
  task :cold do
    puts "There's no cold task for this project, just deploy normally"
  end
end
