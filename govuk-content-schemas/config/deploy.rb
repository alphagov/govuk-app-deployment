set :application, "govuk-content-schemas"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, %w(backend publishing_api)

load 'defaults'

after "deploy:notify", "deploy:notify:github"
