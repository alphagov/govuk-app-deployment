set :application, "signon"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, "backend"
set :repo_name,    "signonotron2"

set :skip_cdn_tasks, true
set :run_migrations_by_default, true

load 'defaults'
load 'ruby'
load 'deploy/assets'

load 'govuk_admin_template'

namespace :users do
  desc "create a new Sign-on-o-tron user. cap users:create name='User name' email='user@bloggs.com'. Optionally, you can add github and twitter handles too."
  task :create, only: { primary: true }, roles: :app do
    rails_env = fetch(:rails_env, "production")
    user_args = {
      :name => ENV['name'],
      :email => ENV['email']
    }
    user_args[:github] = ENV['github'] if ENV['github']
    user_args[:twitter] = ENV['twitter'] if ENV['twitter']
    run <<-CMD
      cd #{latest_release}; #{rake} RAILS_ENV=#{rails_env} users:create #{user_args.collect { |k, v| "#{k}=\"#{v}\"" }.join(' ')}
    CMD
  end
end

after "deploy:upload_initializers", "deploy:symlink_mailer_config"
after "deploy:notify", "deploy:notify:errbit"
