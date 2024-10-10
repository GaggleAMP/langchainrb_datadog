# frozen_string_literal: true

class TestLLMResponse < Langchain::LLM::BaseResponse
  def completions
    return unless (value = raw_response[:completions])

    [
      { message: { role: 'assistant', content: value } }
    ]
  end

  def completion = completions.first

  def embeddings
    return unless (value = raw_response[:embeddings])

    [value]
  end

  def embedding = embeddings.first

  def prompt_tokens = 1
  def completion_tokens = 4
  def total_tokens = 5
end
