# frozen_string_literal: true

require 'langchainrb'
require 'faraday'

require_relative 'datadog/version'
require_relative 'datadog/tracing'
require_relative 'datadog/llm'
require_relative 'datadog/vectorsearch'

module Langchain
  # Datadog LLM Observability integration with Langchain.rb.
  module Datadog
    extend self # rubocop:disable Style/ModuleFunction

    # Values that are considered false when parsing environment variables..
    FALSE_VALUES = [false, 0, '0', 'f', 'F', 'false', 'FALSE', 'off', 'OFF'].freeze

    # @!attribute [rw] enabled
    #   @return [Boolean] whether to submit data to LLM Observability
    #
    # @!attribute [rw] site
    #   @return [String] the Datadog site to submit the LLM data.
    #
    # @!attribute [rw] api_key
    #   @return [String] the Datadog API key
    #
    # @!attribute [rw] ml_app
    #   @return [String] the name of the LLM application
    attr_writer :enabled, :site, :api_key, :ml_app

    def enabled
      return @enabled unless @enabled.nil?

      @enabled = !FALSE_VALUES.include?(ENV.fetch('DD_LLMOBS_ENABLED', '1'))
    end

    def enabled? = !!enabled

    def site
      @site ||= if defined? ::Datadog
                  ::Datadog.configuration.site
                else
                  ENV.fetch('DD_SITE', 'datadoghq.com')
                end
    end

    def api_key
      @api_key ||= if defined? ::Datadog
                     ::Datadog.configuration.api_key
                   else
                     ENV.fetch('DD_API_KEY')
                   end
    end

    def ml_app
      @ml_app ||= ENV['DD_LLMOBS_ML_APP'] || \
                  if defined? ::Datadog
                    ::Datadog.configuration.service
                  else
                    ENV.fetch('DD_LLMOBS_ML_APP')
                  end
    end
  end
end

# Eager load all Langchain::LLM classes to ensure that the Datadog::LLM
# module is prepended to all of them.
Zeitwerk::Loader.eager_load_namespace(Langchain::LLM) rescue Zeitwerk::NameError ? nil : raise \
  if defined?(Zeitwerk)

# Find all classes inheriting from Langchain::LLM::Base and prepend the
# Datadog::LLM module to capture LLM calls and report them to the Datadog
# LLM Observability API.
Langchain::LLM::Base.subclasses.each do |klass|
  klass.prepend Langchain::Datadog::LLM
end

# Eager load all Langchain::Vectorsearch classes to ensure that the
# Datadog::Vectorsearch module is prepended to all of them.
Zeitwerk::Loader.eager_load_namespace(Langchain::Vectorsearch) rescue Zeitwerk::NameError ? nil : raise \
  if defined?(Zeitwerk)

# Find all classes inheriting from Langchain::Vectorsearch::Base and prepend the
# Datadog::Vectorsearch module to capture LLM calls and report them to the
# Datadog LLM Observability API.
Langchain::Vectorsearch::Base.subclasses.each do |klass|
  klass.prepend Langchain::Datadog::Vectorsearch
end
