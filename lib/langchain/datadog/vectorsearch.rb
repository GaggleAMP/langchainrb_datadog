# frozen_string_literal: true

module Langchain
  module Datadog
    # Implements hooks for Langchain::Vectorsearch module classes to capture LLM
    # calls and report them to the Datadog LLM Observability API.
    module Vectorsearch
      include Langchain::Datadog::Tracing

      # List of various attributes that store vectors.
      VECTOR_ATTRIBUTES = %w[embedding vector input_vector values].freeze

      def add_texts(...)
        return super unless Datadog.enabled?

        span(kind: 'workflow') { super }
      end

      def update_texts(...)
        return super unless Datadog.enabled?

        span(kind: 'workflow') { super }
      end

      def similarity_search(query:, **)
        return super unless Datadog.enabled?

        parameters = { query: }

        # Retrieval is not a valid root span kind, therefore when called
        # directly it's wrapped in a workflow span.
        if Tracing.active_parent_id == 'undefined'
          return span(parameters, kind: 'workflow') do
            span(parameters) { super }
          end
        end

        span(parameters) { super }
      end

      def similarity_search_with_hyde(query:, **)
        return super unless Datadog.enabled?

        parameters = { query: }

        span(parameters, kind: 'workflow') { super }
      end

      def ask(question:, **)
        return super unless Datadog.enabled?

        parameters = { question: }

        span(parameters, kind: 'workflow') { super }
      end

      private

      def span(parameters = {}, kind: 'retrieval')
        previous_parent_id = Tracing.active_parent_id
        Tracing.start_span

        start_ns = (Time.now.to_r * 1_000_000_000).to_i
        results  = yield
        duration = (Time.now.to_r * 1_000_000_000).to_i - start_ns

        trace([{
          name: caller_locations(1, 1)[0].label.gsub(' ', '_'),
          span_id: Tracing.active_span_id.to_s,
          trace_id: Tracing.active_trace_id.to_s,
          parent_id: Tracing.active_parent_id&.to_s || 'undefined',
          start_ns:,
          duration:,
          meta: {
            kind:,
            input: input(parameters),
            output: (output(results) if kind == 'retrieval')
          }.compact
        }.compact])

        results
      ensure
        Tracing.end_span(parent_id: previous_parent_id)
      end

      def input(parameters)
        case parameters
        in { query: value } then { value: }
        in { question: value } then { value: }
        else nil
        end
      end

      def output(results)
        documents = results.map do |result|
          next { text: result.to_s } unless result.is_a? Hash

          id    = result['id']
          score = result['score']

          name =
            result['name'] ||
            result.dig('metadata', 'name') ||
            result.dig('metadata', 'title') ||
            result.dig('metadata', 'filename') ||
            result.dig('metadata', 'url') ||
            result.dig('metadata', 'id')

          text =
            result['content'] ||
            result['document'] ||
            result['input'] ||
            result['payload'] ||
            result.dig('data', 'content') ||
            result.dig('metadata', 'content') ||
            result.except(*VECTOR_ATTRIBUTES, 'name', 'score', 'id').to_json

          { text: text&.to_s, name:, score:, id: }.compact
        end

        { documents: }
      end
    end
  end
end
