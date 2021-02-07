require 'spec_helper'

describe Weather::API, type: :api do
  def generate_weather_data
    {
      name: Faker::Lorem.word,
      main: {
        temp: Faker::Number.number(digits: 2)
      }
    }
  end

  def generate_response_data_formatted(data)
    {
      'city' => data.dig(:data, :name),
      'temperature' => data.dig(:data, :main, :temp),
      'unit' => unit
    }
  end

  def generate_request_response_data(data = generate_weather_data)
    { status: status, data: data }
  end

  subject { call_api }
  let(:weather_data) { generate_request_response_data }
  let(:status) { 200 }
  let(:unit) { 'fahrenheit' }
  let(:response) { generate_response_data_formatted(weather_data) }

  describe 'GET /weather/locations/:location_id' do
    context 'GET /weather/locations' do
      it 'returns 404' do
        expect(subject.status).to eq(404)
      end
    end

    context 'GET /weather/locations/1' do
      before do
        allow_any_instance_of(OpenWeatherMapRequester).to receive(:get)
          .with('/weather', id: 1, units: 'imperial')
          .and_return(weather_data)
      end

      it 'returns 200' do
        expect(subject.status).to eq(200)
      end

      it 'returns the weather information' do
        expect(subject.body).to eq(response.to_json)
      end
    end

    context 'GET /weather/locations/a' do
      let(:error) { { error: 'location_id is invalid' }.to_json }

      it 'returns 400' do
        expect(subject.status).to eq(400)
      end

      it 'returns error message' do
        expect(subject.body).to eq(error)
      end
    end
  end

  describe 'GET /weather/summary' do
    let(:params) { {} }
    subject { call_api(params) }

    context 'when is invalid' do
    let(:error) { { error: 'unit is missing, unit does not have a valid value, locations is missing'}.to_json }

      it 'returns 400' do
        expect(subject.status).to eq(400)
      end

      it 'returns error message of validations' do
        expect(subject.body).to eq(error)
      end
    end

    context 'with params and one location' do
      let(:unit) { 'celsius' }
      let(:params) do
        {
          unit: unit,
          locations: '1'
        }
      end


      before do
        allow_any_instance_of(OpenWeatherMapRequester).to receive(:get)
          .with('/weather', id: 1, units: 'metric')
          .and_return(weather_data)
      end

      it 'returns 200' do
        expect(subject.status).to eq(200)
      end

      it 'returns the weather summary' do
        expect(JSON.parse(subject.body)).to match_array([response])
      end
    end

    context 'with params and two or more location' do
      let(:unit) { 'celsius' }
      let(:data_1) { generate_request_response_data }
      let(:data_2) { generate_request_response_data }
      let(:data_3) { generate_request_response_data }
      let(:response_1) { generate_response_data_formatted(data_1) }
      let(:response_2) { generate_response_data_formatted(data_2) }
      let(:response_3) { generate_response_data_formatted(data_3) }

      let(:params) do
        {
          unit: unit,
          locations: '1,2,3'
        }
      end

      before do
        allow_any_instance_of(OpenWeatherMapRequester).to receive(:get)
          .with('/weather', id: 1, units: 'metric')
          .and_return(data_1)
        allow_any_instance_of(OpenWeatherMapRequester).to receive(:get)
          .with('/weather', id: 2, units: 'metric')
          .and_return(data_2)
        allow_any_instance_of(OpenWeatherMapRequester).to receive(:get)
          .with('/weather', id: 3, units: 'metric')
          .and_return(data_3)
      end

      it 'returns 200' do
        expect(subject.status).to eq(200)
      end

      it 'returns the weather summary' do
        expect(JSON.parse(subject.body)).to match_array([response_1, response_2, response_3])
      end
    end

    context 'when unit is invalid' do
      let(:error) { { error: 'unit does not have a valid value' }.to_json }
      let(:params) do
        {
          unit: 'a',
          locations: '1'
        }
      end

      it 'returns 400' do
        expect(subject.status).to eq(400)
      end

      it 'returns an error message' do
        expect(subject.body).to eq(error)
      end
    end

    context 'when locations is invalid' do
      let(:error) { { error: 'locations is invalid' }.to_json }
      let(:params) do
        {
          unit: 'celsius',
          locations: 'b'
        }
      end

      it 'returns 400' do
        expect(subject.status).to eq(400)
      end

      it 'returns an error message' do
        expect(subject.body).to eq(error)
      end
    end
  end
end