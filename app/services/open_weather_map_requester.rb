class OpenWeatherMapRequester < Requester

  BASE_URI = ENV['BASE_URI']
  APP_ID = ENV['APP_ID']

  def initialize
    super(BASE_URI)
  end

  def get(path, **params)
    super(path, {**params, appid: APP_ID})
  end
end