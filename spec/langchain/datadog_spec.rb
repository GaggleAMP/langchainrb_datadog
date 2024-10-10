# frozen_string_literal: true

RSpec.describe Langchain::Datadog do
  it 'has a version number' do
    expect(described_class::VERSION).not_to be nil
  end

  describe 'configuration' do
    before do
      # Clear any previously set instance variables
      described_class.instance_variables.each do |var|
        described_class.instance_variable_set(var, nil)
      end
    end

    it 'is enabled by default' do
      expect(described_class.enabled?).to be true
    end

    it 'can be disabled via environment variable' do
      allow(ENV).to receive(:fetch).with('DD_LLMOBS_ENABLED', '1').and_return('false')
      expect(described_class.enabled?).to be false
    end

    it 'returns the default site' do
      expect(described_class.site).to eq('datadoghq.com')
    end

    it 'fetches the API key from the environment' do
      allow(ENV).to receive(:fetch).with('DD_API_KEY').and_return('test_api_key')
      expect(described_class.api_key).to eq('test_api_key')
    end

    it 'fetches the ML app name from the environment' do
      allow(ENV).to receive(:fetch).with('DD_LLMOBS_ML_APP').and_return('test_ml_app')
      expect(described_class.ml_app).to eq('test_ml_app')
    end
  end
end
