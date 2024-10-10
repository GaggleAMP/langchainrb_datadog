# frozen_string_literal: true

class TestVectorsearch < Langchain::Vectorsearch::Base
  prepend Langchain::Datadog::Vectorsearch

  def add_texts(texts:)
    texts.map { llm.embed(text: _1).embedding }
  end

  def update_texts(texts:, ids:)
    texts.zip(ids).map { llm.embed(text: _1).embedding }
  end

  def similarity_search(query:)
    llm.embed(text: query).embedding
    [{ 'id' => '1', 'score' => 0.9, 'name' => nil, 'content' => 'response' }]
  end

  def similarity_search_with_hyde(query:)
    hyde_completion = llm.complete(prompt: "hyde_prompt: #{query}").completion
    similarity_search(query: hyde_completion)
  end

  def ask(question:)
    results = similarity_search(query: question)
    llm.chat(messages: [{ role: 'user', content: "#{results.join}/#{question}" }])
  end
end
