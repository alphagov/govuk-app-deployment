=begin
Rails apps have a rake task which will publish their special routes, non-
rails tasks do not. This cap task provides a way for non-rails apps to
publish their special routes to the publishing api.

Because this cap task will be run on the jenkins deploy machine in the
environment, it will be able to connect to the publishing API to send these
messages.

USAGE:

1. include this file in your cap `deploy.rb` recipe using:

load 'publish_special_routes_non_rails'

2. ensure that you set an absolute path to a file containing the JSON data to
be posted to the publishing api, e.g.

set :special_route_file,  File.dirname(__FILE__) + "/external_link_tracker_special_route.json"

=end

require 'json'

namespace :deploy do
  namespace :publishing_api do
    desc 'Publish special routes via publishing api'
    task :publish_special_routes_non_rails, :only => { :primary => true, :draft => false } do
      json = File.read(special_route_file)
      base_path = JSON.parse(json)['routes'][0]['path']

      top.upload special_route_file.to_s, "#{release_path}/special_routes.json"
      publishing_api_host = "https://publishing-api.#{ENV['GOVUK_APP_DOMAIN']}"
      run %(govuk_setenv #{application} curl -sS -XPUT -H "Authorization: Bearer $PUBLISHING_API_BEARER_TOKEN" -H "Content-type: application/json" #{publishing_api_host}/content#{base_path} -d @#{release_path}/special_routes.json)
    end
  end
end

after "deploy:symlink", "deploy:publishing_api:publish_special_routes_non_rails"
