require 'net/http'
require 'json'

class Requester
  MAX_REQUESTS_PER_MINUTE = 60
  MAX_REQUEST_PER_DAY = 10000
  TOTAL_SECONDS_MINUTE = 60
  TOTAL_SECOND_DAY = 86400

  @@rate_limiter_minute = RateLimiter.new(MAX_REQUESTS_PER_MINUTE, TOTAL_SECONDS_MINUTE)
  @@rate_limiter_daily = RateLimiter.new(MAX_REQUEST_PER_DAY, TOTAL_SECOND_DAY)

  def initialize(uri)
    @uri = uri
  end

  def get(path, **params)
    url = prepare_url(path)

    url.query = URI.encode_www_form(**params)

    response = evaluate_request(url)

    { status: response.code.to_i, data: parse_data(response) }
  rescue JSON::ParserError
    error(response.code.to_i, response.body)
  rescue Net::ReadTimeout
    error(408, 'Request timeout')
  rescue Net::OpenTimeout
    error(408, 'Request timeout')
  end

  private

  def evaluate_request(url)
    daily_limiter.resolve_request {
      minute_limiter.resolve_request {
        Net::HTTP.get_response(url)
      }
    }
  end

  def prepare_url(path)
    URI("#{@uri}#{path}")
  end

  def parse_data(response)
    JSON.parse(response.body, symbolize_names: true)
  end

  def error(status, message)
    { status: status, data: message }
  end

  def daily_limiter
    @@rate_limiter_daily
  end

  def minute_limiter
    @@rate_limiter_minute
  end
end

