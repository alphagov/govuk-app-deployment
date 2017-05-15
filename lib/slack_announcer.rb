require 'http'

class SlackAnnouncer
  GRAFANA_TIMEOUT = 5

  def initialize(environment_name, slack_url, grafana_timeout: GRAFANA_TIMEOUT)
    @environment_name = environment_name
    @slack_url = slack_url
    @grafana_timeout = grafana_timeout
  end

  def announce_start(repo_name, application, slack_channel = '#govuk-deploy')
    text = "#{environment_emoji} :spinner: Version #{ENV['TAG']} of <https://github.com/alphagov/#{repo_name}|#{application}> is being deployed to *#{@environment_name}*"
    post_text(slack_channel, text)
  end

  def announce_done(repo_name, application, slack_channel = '#govuk-deploy')
    text = "#{environment_emoji} :white_check_mark: Version #{ENV['TAG']} of <https://github.com/alphagov/#{repo_name}|#{application}> was just deployed to *#{@environment_name}*"

    url = dashboard_url(dashboard_host_name, repo_name)
    if url
      text += "\n:chart_with_upwards_trend: Why not check out the <#{url}|#{application} deployment dashboard>?"
    end

    post_text(slack_channel, text)
  end

  def post_text(slack_channel, text)
    return unless %w(production staging).include?(@environment_name)

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

  def environment_emoji
    ":govuk-#{@environment_name}:"
  end

  def dashboard_host_name
    {
      "production" => "grafana.publishing.service.gov.uk",
      "staging" => "grafana.staging.publishing.service.gov.uk",
    }[@environment_name]
  end

  def dashboard_url(host_name, application_name)
    Timeout.timeout(@grafana_timeout) do
      url = "https://#{host_name}/api/dashboards/file/deployment_#{application_name}.json"
      return nil unless (200..399).cover?(HTTP.get(url).code)

      "https://#{host_name}/dashboard/file/deployment_#{application_name}.json"
    end
  rescue => e
    puts "Unable to connect to grafana server: #{e.message}"
    nil
  end
end
