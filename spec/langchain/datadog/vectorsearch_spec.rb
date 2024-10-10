# frozen_string_literal: true

require_relative 'test_vectorsearch'
require_relative 'test_llm'

RSpec.describe Langchain::Datadog::Vectorsearch do
  subject { TestVectorsearch.new(llm: TestLLM.new) }

  let(:datadog_client_double) { double('Faraday') }

  before do
    allow(Langchain::Datadog).to receive(:enabled?).and_return(true)
    allow(Langchain::Datadog).to receive(:api_key).and_return('test_api_key')
    allow(Langchain::Datadog).to receive(:site).and_return('datadoghq.com')
    allow(Langchain::Datadog).to receive(:ml_app).and_return('test_ml_app')

    allow(subject).to receive(:datadog_client).and_return(datadog_client_double)
    allow(subject.llm).to receive(:datadog_client).and_return(datadog_client_double)
  end

  describe '#add_texts' do
    before { expect(datadog_client_double).to receive(:post).exactly(2).times }

    it 'calls the super method' do
      subject.add_texts(texts: ['hello'])
    end
  end

  describe '#update_texts' do
    before { expect(datadog_client_double).to receive(:post).exactly(2).times }

    it 'calls the super method' do
      subject.update_texts(texts: ['hello'], ids: ['1'])
    end
  end

  describe '#similarity_search' do
    before { expect(datadog_client_double).to receive(:post).exactly(2).times }

    it 'calls the super method' do
      subject.similarity_search(query: 'what?')
    end
  end

  describe '#similarity_search_with_hyde' do
    before { expect(datadog_client_double).to receive(:post).exactly(4).times }

    it 'calls the super method' do
      subject.similarity_search_with_hyde(query: 'what?')
    end
  end

  describe '#ask' do
    before { expect(datadog_client_double).to receive(:post).exactly(4).times }

    it 'calls the super method and returns a response' do
      expect(subject.ask(question: 'what?')).to be_a(Langchain::LLM::BaseResponse)
    end
  end
end
