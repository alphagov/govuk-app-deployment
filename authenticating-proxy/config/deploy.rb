set :application, "authenticating-proxy"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, [
  "draft_cache",
]

load 'defaults'
load 'ruby'

set :rails_env, 'production'

namespace :deploy do
  task :cold do
    puts "There's no cold task for this project, just deploy normally"
  end
end
