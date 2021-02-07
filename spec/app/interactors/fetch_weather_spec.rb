require 'spec_helper'

describe FetchWeather do
  subject { described_class.call(params) }
  let(:response) { { status: status, data: data } }
  let(:params) { { location_id: Faker::Number.number(digits: 2) } }

  describe '.call' do

    context 'when is success' do
      let(:status) { 200 }
      let(:unit) { :fahrenheit }
      let(:data) do
        {
          name: Faker::Lorem.word,
          main: {
            temp: Faker::Number.number(digits: 2)
          }
        }
      end
      let(:result) do
        {
          city: data[:name],
          temperature: data.dig(:main, :temp),
          unit: unit
        }
      end

      before do
        allow_any_instance_of(OpenWeatherMapRequester).to receive(:get)
          .with('/weather', id: params[:location_id], units: 'imperial')
          .and_return(response)
      end

      it 'expected to have context with success' do 
        expect(subject.success?).to be_truthy
      end

      it 'expected to have context of status 200' do
        expect(subject.status).to eq(200)
      end

      it 'expected to have context with result of weather data' do
        expect(subject.result).to eq(result)
      end
    end

    context 'when is a failure' do
      let(:status) { 404 }
      let(:data) do
        {
          cod: 404,
          message: 'City not found!'
        }
      end

      before do
        allow_any_instance_of(OpenWeatherMapRequester).to receive(:get)
          .with('/weather', id: params[:location_id], units: 'imperial')
          .and_return(response)
      end

      it 'expected to have context with failure' do 
        expect(subject.failure?).to be_truthy
      end

      it 'expected to have context of status 404' do
        expect(subject.status).to eq(404)
      end

      it 'expected to have context with the message error' do
        expect(subject.result).to eq(data)
      end
    end
  end
end