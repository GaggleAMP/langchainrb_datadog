# frozen_string_literal: true

module Langchain
  module Datadog
    # Implements the Datadog LLM Observability API tracing.
    module Tracing
      # Returns the active trace ID.
      def self.active_trace_id
        @active_trace_id ||=
          (::Datadog::Tracing.active_trace&.id if defined? ::Datadog) ||
          next_id
      end

      # Returns the active span ID.
      def self.active_span_id
        @active_span_id ||
          (::Datadog::Tracing.active_span&.id if defined? ::Datadog)
      end

      # Returns the active parent span ID.
      def self.active_parent_id
        @active_parent_id
      end

      # Starts a new span, setting the parent ID to the active span ID.
      def self.start_span(parent_id: active_span_id)
        @active_parent_id = parent_id
        @active_span_id   = next_id
      end

      # Ends the active span, setting the parent ID to the given value.
      def self.end_span(parent_id: nil)
        @active_span_id   = active_parent_id
        @active_parent_id = parent_id
      end

      # Starts a new workflow span.
      def self.workflow(input = nil, name: nil, &block)
        return yield unless Datadog.enabled?

        span(input, name:, kind: 'workflow', &block)
      end

      # Starts a new agent span.
      def self.agent(input = nil, name: nil, &block)
        return yield unless Datadog.enabled?

        span(input, name:, kind: 'agent', &block)
      end

      private_class_method def self.span(input = nil, name: nil, kind: 'workflow')
        previous_parent_id = active_parent_id
        start_span

        start_ns = (Time.now.to_r * 1_000_000_000).to_i
        output   = yield
        duration = (Time.now.to_r * 1_000_000_000).to_i - start_ns

        input_value  = { value: input } if input
        output_value = { value: output } if output

        trace([{
          name: name || caller_locations(1, 1)[0].label.gsub(' ', '_'),
          span_id: active_span_id.to_s,
          trace_id: active_trace_id.to_s,
          parent_id: active_parent_id&.to_s || 'undefined',
          start_ns:,
          duration:,
          meta: {
            kind:,
            input: input_value,
            output: output_value
          }.compact
        }.compact])

        output
      ensure
        end_span(parent_id: previous_parent_id)
      end

      module_function

      def next_id
        return ::Datadog::Tracing::Utils.next_id if defined? ::Datadog

        rand 1..((1 << 62) - 1)
      end
      private_class_method :next_id

      def trace(spans)
        datadog_client.post do |request|
          request.url 'trace/spans'
          request.body = {
            data: {
              type: 'span',
              attributes: {
                ml_app: Datadog.ml_app,
                spans:
              }
            }
          }
        end
      end
      private_class_method :trace

      def datadog_client
        @datadog_client ||= Faraday.new(
          url: "https://api.#{Datadog.site}/api/intake/llm-obs/v1/",
          headers: { 'DD-API-KEY' => Datadog.api_key, 'Content-Type' => 'application/json' }
        ) do |faraday|
          faraday.request :json
          faraday.response :json
          faraday.response :logger, Langchain.logger, headers: true, bodies: true do |formatter|
            formatter.filter(/(DD-API-KEY: )("\w+")/, '\1[REDACTED]')
          end
        end
      end
      private_class_method :datadog_client
    end
  end
end
