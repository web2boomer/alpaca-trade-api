# frozen_string_literal: true

RSpec.describe Alpaca::Trade::Api do
  it 'has a version number' do
    expect(Alpaca::Trade::Api::VERSION).not_to be nil
  end

  describe '.configure' do
    let(:key_id) { 'KEY_ID' }
    let(:key_secret) { 'KEY_S3CRET' }

    after do
      Alpaca::Trade::Api.reset
    end

    it 'defaults to expected values' do
      saved = ENV.to_h.slice('ALPACA_API_KEY_ID', 'ALPACA_API_SECRET_KEY', 'ALPACA_BASE_URL')
      ENV['ALPACA_API_KEY_ID'] = key_id
      ENV['ALPACA_API_SECRET_KEY'] = key_secret
      ENV.delete('ALPACA_BASE_URL')
      Alpaca::Trade::Api.reset

      config = Alpaca::Trade::Api.configuration
      expect(config.data_endpoint).to eq('https://data.alpaca.markets')
      expect(config.endpoint).to eq('https://api.alpaca.markets')
      expect(config.key_id).to eq(key_id)
      expect(config.key_secret).to eq(key_secret)
    ensure
      saved.each { |k, v| ENV[k] = v }
      (saved.keys - saved.compact.keys).each { |k| ENV.delete(k) }
    end

    it 'uses ALPACA_BASE_URL env var when set' do
      saved = ENV.to_h.slice('ALPACA_API_KEY_ID', 'ALPACA_API_SECRET_KEY', 'ALPACA_BASE_URL')
      ENV['ALPACA_API_KEY_ID'] = key_id
      ENV['ALPACA_API_SECRET_KEY'] = key_secret
      ENV['ALPACA_BASE_URL'] = 'https://paper-api.alpaca.markets'
      Alpaca::Trade::Api.reset

      expect(Alpaca::Trade::Api.configuration.endpoint).to eq('https://paper-api.alpaca.markets')
    ensure
      saved.each { |k, v| ENV[k] = v }
      saved.each { |k, _| ENV.delete(k) unless saved[k] }
    end

    it 'lets user configure extra_keys' do
      Alpaca::Trade::Api.configure do |config|
        config.endpoint = 'https://live.alapca.markets'
        config.key_id = 'ANOTHER_KEY_ID'
        config.key_secret = 'ANOTHER_KEY_S3CRET'
      end

      expect(Alpaca::Trade::Api.configuration.endpoint).to eq('https://live.alapca.markets')
      expect(Alpaca::Trade::Api.configuration.key_id).to eq('ANOTHER_KEY_ID')
      expect(Alpaca::Trade::Api.configuration.key_secret).to eq('ANOTHER_KEY_S3CRET')
    end
  end
end
