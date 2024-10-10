# frozen_string_literal: true

require_relative 'test_llm_response'

class TestLLM < Langchain::LLM::Base
  prepend Langchain::Datadog::LLM

  def chat(_params = {})
    TestLLMResponse.new({ completions: 'chat response' })
  end

  def complete(_params = {})
    TestLLMResponse.new({ completions: 'complete response' })
  end

  def embed(_params = {})
    TestLLMResponse.new({ embeddings: 'embed response' })
  end

  def summarize(_params = {})
    TestLLMResponse.new({ completions: 'summarize response' })
  end
end
