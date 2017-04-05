require 'http'

class SlackAnnouncer
  def initialize(environment_name, slack_url)
    @environment_name = environment_name
    @slack_url = slack_url
  end

  def announce(repo_name, application, slack_channel = "#2ndline")
    return unless %w(production staging).include?(@environment_name)

    message_payload = {
      username: "Badger",
      icon_emoji: ":badger:",
      text: "<https://github.com/alphagov/#{repo_name}|#{application}> was just deployed to *#{@environment_name}*",
      mrkdwn: true,
      channel: slack_channel,
    }

    HTTP.post(@slack_url, body: JSON.dump(message_payload))
  rescue => e
    puts "Release notification to slack failed: #{e.message}"
  end
end
