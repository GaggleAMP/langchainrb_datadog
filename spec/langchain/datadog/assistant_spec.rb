# frozen_string_literal: true

require_relative 'test_llm'
require_relative 'test_tool'

RSpec.describe Langchain::Datadog::Assistant do
  before do
    allow(Langchain::Assistant::LLM::Adapter).to \
      receive(:build).and_return(test_llm_adapter)
  end

  let(:test_llm_adapter) do
    double allowed_tool_choices: %w[auto],
           available_tool_names: %w[test_tool],
           support_system_message?: false,
           extract_tool_call_args: ['test_tool__invoke', 'test_tool', 'invoke', {}],
           tool_role: 'tool'
  end

  subject { Langchain::Assistant.new(llm: TestLLM.new, tools: [TestTool.new]) }

  let(:datadog_client_double) { double('Faraday') }

  before do
    allow(Langchain::Datadog).to receive(:enabled?).and_return(true)
    allow(Langchain::Datadog).to receive(:api_key).and_return('test_api_key')
    allow(Langchain::Datadog).to receive(:site).and_return('datadoghq.com')
    allow(Langchain::Datadog).to receive(:ml_app).and_return('test_ml_app')

    allow(subject).to receive(:datadog_client).and_return(datadog_client_double)
    allow(subject.llm).to receive(:datadog_client).and_return(datadog_client_double)
    allow(Langchain::Datadog::Tracing).to receive(:datadog_client).and_return(datadog_client_double)
  end

  describe '#run' do
    before { expect(datadog_client_double).to receive(:post) }

    it 'calls the super method' do
      allow(Langchain.logger).to receive(:warn) # Langchain::Assistant - No messages to process

      subject.run
    end
  end

  describe '#run_tool' do
    before { expect(datadog_client_double).to receive(:post) }

    it 'calls the super method' do
      allow(test_llm_adapter).to \
        receive(:build_message).and_return(double(role: 'tool', content: 'test', image_url: nil))

      subject.send(:run_tool, { 'id' => 'test' })
    end
  end
end
