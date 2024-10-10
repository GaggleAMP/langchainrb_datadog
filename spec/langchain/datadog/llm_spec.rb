# frozen_string_literal: true

require_relative 'test_llm'

RSpec.describe Langchain::Datadog::LLM do
  subject { TestLLM.new }

  let(:datadog_client_double) { double('Faraday') }

  before do
    allow(Langchain::Datadog).to receive(:enabled?).and_return(true)
    allow(Langchain::Datadog).to receive(:api_key).and_return('test_api_key')
    allow(Langchain::Datadog).to receive(:site).and_return('datadoghq.com')
    allow(Langchain::Datadog).to receive(:ml_app).and_return('test_ml_app')

    allow(subject).to receive(:datadog_client).and_return(datadog_client_double)
  end

  describe '#chat' do
    before { expect(datadog_client_double).to receive(:post) }

    it 'calls the super method and returns a response' do
      expect(subject.chat(messages: [{ content: 'hello' }])).to be_a(Langchain::LLM::BaseResponse)
    end
  end

  describe '#complete' do
    before { expect(datadog_client_double).to receive(:post) }

    it 'calls the super method and returns a response' do
      expect(subject.complete(prompt: 'hello')).to be_a(Langchain::LLM::BaseResponse)
    end
  end

  describe '#embed' do
    before { expect(datadog_client_double).to receive(:post) }

    it 'calls the super method and returns a response' do
      expect(subject.embed(text: 'hello')).to be_a(Langchain::LLM::BaseResponse)
    end
  end

  describe '#summarize' do
    before { expect(datadog_client_double).to receive(:post) }

    it 'calls the super method and returns a response' do
      expect(subject.summarize(text: 'hello')).to be_a(Langchain::LLM::BaseResponse)
    end
  end
end
