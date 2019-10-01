require "tempfile"
require "net/http"
require "aws-sdk-s3"

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
  file = Tempfile.new(application.to_s)
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

def fetch_from_s3_to_tempfile(bucket, key)
  s3 = Aws::S3::Client.new(region: ENV["AWS_DEFAULT_REGION"])
  file = Tempfile.new(application.to_s)
  file.binmode

  object = {
    :bucket => bucket,
    :key    => key,
  }

  s3.get_object(object, target: file)
  file
end

def setup_http_request(url)
  uri = URI.parse(url)
  Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == "https") do |http|
    req = Net::HTTP::Get.new(uri.request_uri)
    if uri.user && uri.password
      req.basic_auth(uri.user, uri.password)
    end
    yield http, req
  end
end
