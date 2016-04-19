require 'tempfile'
require 'net/http'

def fetch_last_build_number(base_url)
  number = nil
  setup_http_request("#{base_url}/lastSuccessfulBuild/buildNumber") do |http, req|
    response = http.request(req)
    raise "Got #{response.code} fetching artefact" unless response.code.to_i == 200
    number = response.body.strip
  end
  number
end

def fetch_to_tempfile(url)
  file = Tempfile.new("#{application}")
  file.binmode
  setup_http_request(url) do |http, req|
    http.request req do |response|
      raise "Got #{response.code} fetching artefact" unless response.code.to_i == 200

      response.read_body do |chunk|
        file.write chunk
      end
    end
  end
  file.rewind
  file
end

def setup_http_request(url)
  uri = URI.parse(url)
  Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
    req = Net::HTTP::Get.new(uri.request_uri)
    req.basic_auth(uri.user, uri.password)
    yield http, req
  end
end
