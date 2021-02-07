class App < Grape::API
  mount Weather::API
  format :json

  route :any, '*path' do
    error!({ error: 'Not Found', detail: "No such route '#{request.path}'" }, 404)
  end
end