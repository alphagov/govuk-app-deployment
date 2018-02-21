set :application, "email-alert-service"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, %w(email_alert_api backend)

load 'defaults'
load 'ruby'

set :copy_exclude, [
  '.git/*',
]
