# frozen_string_literal: true

module Langchain
  module Datadog
    # Implements hooks for Langchain::Assistant class to capture LLM
    # calls and report them to the Datadog LLM Observability API.
    module Assistant
      include Langchain::Datadog::Tracing

      def run(...)
        return super unless Datadog.enabled?

        span do
          super
          extract_content messages.last if state == :completed
        end

        messages
      end

      private

      def run_tool(tool_call, ...)
        return super unless Datadog.enabled?

        Tracing.send(:span, tool_call.to_json, kind: 'tool') do
          super
          extract_content messages.last
        end

        messages
      end

      def span
        previous_parent_id = Tracing.active_parent_id
        Tracing.start_span

        input_messages = {
          messages: messages.map do |message|
            { content: extract_content(message), role: message.role }
          end
        }

        start_ns = (Time.now.to_r * 1_000_000_000).to_i
        output   = yield
        duration = (Time.now.to_r * 1_000_000_000).to_i - start_ns

        output_value = { value: output } if output

        trace([{
          name: caller_locations(1, 1)[0].label,
          span_id: Tracing.active_span_id.to_s,
          trace_id: Tracing.active_trace_id.to_s,
          parent_id: Tracing.active_parent_id&.to_s || 'undefined',
          start_ns:,
          duration:,
          meta: {
            kind: 'agent',
            input: input_messages,
            output: output_value
          }.compact,
          metrics:
        }.compact])

        output
      ensure
        Tracing.end_span(parent_id: previous_parent_id)
      end

      def metrics
        input_tokens  = total_prompt_tokens
        output_tokens = total_completion_tokens

        metrics = { input_tokens:, output_tokens:, total_tokens: }.compact

        metrics.empty? ? nil : metrics
      end

      def extract_content(message)
        return nil unless message.respond_to?(:content) && message.respond_to?(:image_url)

        [message.content, message.image_url].join(' ').strip
      end
    end
  end
end
