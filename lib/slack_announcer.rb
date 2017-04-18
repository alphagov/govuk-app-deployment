require 'http'

class SlackAnnouncer
  def initialize(environment_name, slack_url)
    @environment_name = environment_name
    @slack_url = slack_url
  end

  def announce(repo_name, application, slack_channel = "#2ndline")
    return unless %w(production staging).include?(@environment_name)

    text = "<https://github.com/alphagov/#{repo_name}|#{application}> was just deployed to *#{@environment_name}*"
    if repo_name == "whitehall"
      text += "\n:chart_with_upwards_trend: Why not check out the <https://#{dashboard_host_name}/dashboard/db/prototype-dashboard-whitehall|#{application} deployment dashboard>?"
    end

    message_payload = {
      username: "Badger",
      icon_emoji: ":badger:",
      text: text,
      mrkdwn: true,
      channel: slack_channel,
    }

    HTTP.post(@slack_url, body: JSON.dump(message_payload))
  rescue => e
    puts "Release notification to slack failed: #{e.message}"
  end

  def dashboard_host_name
    {
      "production" => "grafana.publishing.service.gov.uk",
      "staging" => "grafana.staging.publishing.service.gov.uk",
    }[@environment_name]
  end
end
