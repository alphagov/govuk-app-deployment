source "https://rubygems.org/"

gem "capistrano", "2.13.5"
gem "capistrano_rsync_with_remote_cache",
    :git => "https://github.com/alphagov/capistrano_rsync_with_remote_cache",
    :tag => "v2.4.1"

# The net-ssh gem has a bug when reading StrictHostKeyChecking from
# the ssh_config file where the option passed to the connection
# is seen as invalid. This is fixed in an open PR but at this time
# it is unmerged and not released:
# https://github.com/net-ssh/net-ssh/pull/765
gem "net-ssh", "< 6.0"

gem "railsless-deploy", :require => false

gem "aws-sdk-s3"
gem "http", "~> 3.0"
gem "rake"
gem "rubocop-govuk"
gem "webrick"
gem "whenever", "0.7.3"

gem "rspec"
