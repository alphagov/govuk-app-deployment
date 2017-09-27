# Notify
#
# Sends notifications to places when an app has been deployed
#
require "slack_announcer"

namespace :deploy do
  namespace :notify do
    desc "Notifies external services of a successful deployment"
    task :default do
      release_app
      slack_message_done
      graphite_event
    end

    desc "Register the deployment with the 'release' app"
    task :release_app do
      release_app_url = 'https://release.publishing.service.gov.uk'
      manual_resolution_message = "ACTION REQUIRED: Failed to notify Release app of deploy. Please add this deploy manually at #{release_app_url}"

      require "net/http"
      bearer_token = ENV["RELEASE_APP_NOTIFICATION_BEARER_TOKEN"]
      if bearer_token.nil?
        puts "RELEASE_APP_NOTIFICATION_BEARER_TOKEN not set, can't notify Release app of deploy."
        raise manual_resolution_message
      else
        begin
          url = URI.parse("#{release_app_url}/deployments")
          request = Net::HTTP::Post.new(url.path)
          conn = Net::HTTP.new(url.host, url.port)
          conn.use_ssl = true

          form_data = {
            "repo"                    => repository,
            "deployment[version]"     => ENV['TAG'],
            "deployment[environment]" => organisation
          }
          request.set_form_data(form_data)
          request["Accept"] = "application/json"
          request["Authorization"] = "Bearer #{bearer_token}" # So that gds-sso will treat us as an API client
          response = conn.request(request)
          puts "Deployment notification response:"
          puts "#{response.code} #{response.body}"
        rescue => e
          puts "Release notification failed: #{e.message}"
          raise manual_resolution_message
        end
      end
    end

    desc "Announce on Slack the deploy has started"
    task :slack_message_start do
      annoucer = SlackAnnouncer.new(ENV['ORGANISATION'], ENV['BADGER_SLACK_WEBHOOK_URL'])
      annoucer.announce_start(repo_name, application)
    end

    desc "Announce on Slack the deploy has finished"
    task :slack_message_done do
      annoucer = SlackAnnouncer.new(ENV['ORGANISATION'], ENV['BADGER_SLACK_WEBHOOK_URL'])
      annoucer.announce_done(repo_name, application)
    end

    desc "Record the deployment as a Graphite event"
    task :graphite_event do
      require 'json'
      require 'net/http'
      require 'uri'

      begin
        req = Net::HTTP::Post.new('/events/')
        req["Content-Type"] = 'application/json'
        req.body = { what: 'deploy',
                     tags: "#{application} #{ENV['ORGANISATION']} deploys",
                     data: "#{branch} #{current_revision[0, 7]} #{user}" }.to_json
        req.basic_auth(ENV['GRAPHITE_USER'], ENV['GRAPHITE_PASSWORD'])
        Net::HTTP.new('graphite.cluster', '80').start { |http| http.request(req) }
      rescue => e
        puts "Graphite notification failed: #{e.message}"
      end
    end

    task :github, :only => { :primary => true } do
      run_locally "cd #{strategy.local_cache_path}; git push -f #{repository} HEAD:refs/heads/deployed-to-#{ENV['ORGANISATION']}"
    end
  end
end
