set :application, "govuk-cdn-logs-monitor"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, "logs_cdn"

load 'defaults'
load 'ruby'

set :copy_exclude, [
  '.git/*',
]
