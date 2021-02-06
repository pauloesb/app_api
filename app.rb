class App < Grape::API
  mount Weather::API
end