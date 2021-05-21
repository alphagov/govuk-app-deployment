require "http"

class SlackAnnouncer
  def initialize(environment_name, slack_url)
    @environment_name = environment_name
    @slack_url = slack_url
  end

  def announce_start(repo_name, application, slack_channel = "#govuk-deploy")
    return unless staging_or_production?

    text = "#{environment_emoji} :mega: #{version_and_link(repo_name, application)} " \
           "is being deployed to *#{@environment_name}* by #{build_user}"

    post_text(slack_channel, text)
  end

  def announce_done(repo_name, application, slack_channel = "#govuk-deploy")
    return unless staging_or_production?

    text = "#{environment_emoji} :white_check_mark: #{version_and_link(repo_name, application)} " \
           "deployed to *#{@environment_name}* by #{build_user}"

    post_text(slack_channel, text)
  end

  def announce_failed(repo_name, application, slack_channel = "#govuk-deploy")
    return unless staging_or_production?

    text = "#{environment_emoji} :red_circle: #{deploy_build_and_link(repo_name, application)} " \
           "failed to deploy to *#{@environment_name}* by #{build_user}"

    post_text(slack_channel, text)
  end

  def post_text(slack_channel, text)
    message_payload = {
      username: "Badger",
      icon_emoji: ":badger:",
      text: text,
      mrkdwn: true,
      channel: slack_channel,
    }

    HTTP.post(@slack_url, body: JSON.dump(message_payload))
  rescue StandardError => e
    puts "Release notification to slack failed: #{e.message}"
  end

  def version_and_link(repo_name, application)
    "Version #{release_link(repo_name)} of <https://github.com/alphagov/#{repo_name}|#{application}>"
  end

  def release_link(repo_name)
    "<https://release.publishing.service.gov.uk/applications/#{repo_name}/deploy?tag=#{ENV['TAG']}|#{ENV['TAG']}>"
  end

  def deploy_build_and_link(repo_name, application)
    "Version #{failed_deploy_link} of <https://github.com/alphagov/#{repo_name}|#{application}>"
  end

  def failed_deploy_link
    deploy_url = "https://deploy.blue.#{@environment_name}.govuk.digital/job/Deploy_App"
    build_number = ENV["BUILD_NUMBER"]

    "<#{deploy_url}/#{build_number}|#{ENV['TAG']}>"
  end

  def environment_emoji
    ":govuk-#{@environment_name}:"
  end

  def build_user
    ENV.fetch("BUILD_USER", "Jenkins")
  end

  def staging_or_production?
    %w[production staging].include?(@environment_name)
  end
end
