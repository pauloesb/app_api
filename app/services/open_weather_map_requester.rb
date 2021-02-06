class OpenWeatherMapRequester < Requester

  BASE_URI = 'https://api.openweathermap.org/data/2.5'
  APP_ID = 'da87a647b9134afaf5709f33c1abc0b7'

  def initialize
    super(BASE_URI)
  end

  def get(path, **params)
    super(path, {**params, appid: APP_ID})
  end
end