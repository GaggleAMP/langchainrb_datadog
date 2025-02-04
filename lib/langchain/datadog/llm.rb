# frozen_string_literal: true

module Langchain
  module Datadog
    # Implements hooks for Langchain::LLM module classes to capture LLM calls
    # and report them to the Datadog LLM Observability API.
    module LLM
      include Langchain::Datadog::Tracing

      def chat(params = {}, ...)
        return super unless Datadog.enabled?

        parameters = chat_parameters.to_params(params)

        span(parameters) { super }
      end

      def complete(prompt:, **)
        return super unless Datadog.enabled?

        parameters = { prompt: }

        span(parameters) { super }
      end

      def embed(text:, **)
        return super unless Datadog.enabled?

        parameters = { text: }

        span(parameters, kind: 'embedding') { super }
      end

      def summarize(text:, **)
        return super unless Datadog.enabled?

        parameters = { text: }

        span(parameters, kind: 'task') { super }
      end

      private

      def span(parameters, kind: 'llm')
        previous_parent_id = Tracing.active_parent_id
        Tracing.start_span

        start_ns = (Time.now.to_r * 1_000_000_000).to_i
        response = yield
        duration = (Time.now.to_r * 1_000_000_000).to_i - start_ns

        trace([{
          name: caller_locations(1, 1)[0].label,
          span_id: Tracing.active_span_id.to_s,
          trace_id: Tracing.active_trace_id.to_s,
          parent_id: Tracing.active_parent_id&.to_s || 'undefined',
          start_ns:,
          duration:,
          meta: {
            kind:,
            input: input(parameters),
            output: output(response),
            metadata: metadata(parameters, response)
          }.compact,
          metrics: metrics(response)
        }.compact])

        response
      ensure
        Tracing.end_span(parent_id: previous_parent_id)
      end

      def input(parameters)
        case parameters
        in { messages: messages }
          { messages: messages.map { |message| transform_content(message) } }
        in { prompt: value } then { value: }
        in { text: value } then { value: }
        else nil
        end
      end

      def output(response)
        completions = begin; response.completions; rescue NotImplementedError; nil; end
        embeddings  = begin; response.embeddings; rescue NotImplementedError; nil; end

        if completions
          { messages: [completions.dig(0, 'message')&.slice('content', 'role')] }
        elsif embeddings
          { value: embeddings.first&.to_s }
        end
      end

      def metadata(parameters, response)
        temperature    = parameters[:temperature]
        max_tokens     = parameters[:max_tokens] || parameters[:maxTokens]
        model_name     = begin; response.model; rescue NotImplementedError; nil; end
        model_provider = response.class.name.split('::').last.sub(/Response$/, '')

        metadata = { temperature:, max_tokens:, model_name:, model_provider: }.compact

        metadata.empty? ? nil : metadata
      end

      def metrics(response)
        input_tokens  = begin; response.prompt_tokens; rescue NotImplementedError; nil; end
        output_tokens = begin; response.completion_tokens; rescue NotImplementedError; nil; end
        total_tokens  = begin; response.total_tokens; rescue NotImplementedError; nil; end

        metrics = { input_tokens:, output_tokens:, total_tokens: }.compact

        metrics.empty? ? nil : metrics
      end

      def transform_content(message) = {
        content: (if (content = message[:content]).is_a?(Array)
                    content.map do |chunk|
                      chunk[:text] || chunk.dig(:image_url, :url)
                    end.compact.join
                  else
                    content
                  end),
        role: message[:role]
      }
    end
  end
end
