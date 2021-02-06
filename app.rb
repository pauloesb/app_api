require 'zeitwerk'
loader = Zeitwerk::Loader.new
loader.push_dir('./app/routes')
loader.setup

class App < Grape::API
  mount Weather::API
end