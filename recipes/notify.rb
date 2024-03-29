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
      if ENV["NOTIFY_RELEASE_APP"] == "true"
        release_app_url = "https://release.publishing.service.gov.uk"
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

            deployed_to_environment = ENV["ORGANISATION"]

            deployed_sha = if ENV["USE_S3"] == "false"
                             run_locally("cd #{strategy.local_cache_path} && git rev-list -n 1 #{current_revision}")
                           else
                             ENV["FILE_SHA256"]
                           end

            form_data = {
              "repo" => repository,
              "application_by_name" => application_by_name,
              "application_name" => application,
              "deployment[environment]" => deployed_to_environment,
              "deployment[jenkins_user_email]" => ENV["BUILD_USER_EMAIL"],
              "deployment[jenkins_user_name]" => ENV["BUILD_USER"],
              "deployment[deployed_sha]" => deployed_sha,
              "deployment[version]" => ENV["TAG"],
            }
            request.set_form_data(form_data)
            request["Accept"] = "application/json"
            request["Authorization"] = "Bearer #{bearer_token}" # So that gds-sso will treat us as an API client
            response = conn.request(request)
            puts "Deployment notification response:"
            puts "#{response.code} #{response.body}"
          rescue StandardError => e
            puts "Release notification failed: #{e.message}"
            raise manual_resolution_message
          end
        end
      end
    end

    desc "Announce on Slack the deploy has started"
    task :slack_message_start do
      if ENV["SLACK_NOTIFICATIONS"] == "true"
        annoucer = SlackAnnouncer.new(ENV["ORGANISATION"], ENV["BADGER_SLACK_WEBHOOK_URL"])
        annoucer.announce_start(repo_name, application)
      end
    end

    desc "Announce on Slack the deploy has finished"
    task :slack_message_done do
      if ENV["SLACK_NOTIFICATIONS"] == "true"
        annoucer = SlackAnnouncer.new(ENV["ORGANISATION"], ENV["BADGER_SLACK_WEBHOOK_URL"])
        annoucer.announce_done(repo_name, application)
      end
    end

    desc "Announce on Slack that the deploy has failed"
    task :slack_message_failed do
      if ENV["SLACK_NOTIFICATIONS"] == "true"
        annoucer = SlackAnnouncer.new(ENV["ORGANISATION"], ENV["BADGER_SLACK_WEBHOOK_URL"])
        annoucer.announce_failed(repo_name, application)
        if ENV["ORGANISATION"] == "production"
          annoucer.announce_failed(repo_name, application, "#govuk-2ndline-tech")
        end
      end
    end

    desc "Record the deployment as a Graphite event"
    task :graphite_event do
      require "json"
      require "net/http"
      require "uri"

      begin
        graphite_protocol = ENV["GRAPHITE_PORT"] == "443" ? "https" : "http"
        url = URI.parse("#{graphite_protocol}://#{ENV['GRAPHITE_HOST']}/events/")

        req = Net::HTTP::Post.new(url.path)
        req["Content-Type"] = "application/json"
        req.body = { what: "deploy",
                     tags: "#{application} #{ENV['ORGANISATION']} deploys",
                     data: "#{branch} #{current_revision[0, 7]} #{ENV['BUILD_USER']}" }.to_json
        req.basic_auth(ENV["GRAPHITE_USER"], ENV["GRAPHITE_PASSWORD"])
        conn = Net::HTTP.new(url.host, url.port)
        conn.use_ssl = true if graphite_protocol == "https"
        conn.request(req)
      rescue StandardError => e
        puts "Graphite notification failed: #{e.message}"
      end
    end

    task :github, :only => { :primary => true } do
      if !exists?(:custom_git_tag)
        run_locally "cd #{strategy.local_cache_path}; git push -f #{repository} HEAD:refs/heads/deployed-to-#{ENV['ORGANISATION']}"
      else
        run_locally "cd #{strategy.local_cache_path}; git push -f #{repository} HEAD:refs/heads/#{custom_git_tag}"
      end
    end

    task :git_clone_and_tag, :only => { :primary => true } do
      path = strategy.local_cache_path
      revision = source.query_revision(branch) { |cmd| run_locally cmd }
      if File.exist?(path)
        run_locally source.sync(revision, path)
      else
        run_locally "mkdir -p #{path} && #{source.checkout(revision, path)}"
      end
      notify.github
    end

    desc "Makes a copy of the deployed artefact in the S3 bucket for future deployments"
    task :copy_artefact do
      if ENV["USE_S3"]
        s3 = Aws::S3::Client.new(region: ENV["AWS_DEFAULT_REGION"])

        unless ENV["TAG"] == "deployed-to-#{ENV['ORGANISATION']}"
          source_key = "#{application}/#{ENV['TAG']}/#{application}"
          target_key = "#{application}/deployed-to-#{ENV['ORGANISATION']}/#{application}"
          s3.copy_object({ :bucket => ENV["S3_ARTEFACT_BUCKET"],
                           :copy_source => "#{ENV['S3_ARTEFACT_BUCKET']}/#{source_key}",
                           :key => target_key })
          puts "Copying file #{source_key} to #{target_key}."
        end
      end
    end
  end
end
