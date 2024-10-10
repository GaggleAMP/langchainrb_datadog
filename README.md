# Langchain.rb Datadog

Enables LLM observability with Datadog for Langchain.rb.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add langchainrb_datadog

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install langchainrb_datadog

## Usage

Its function is automatic: it hooks into Langchain.rb methods to capture LLM calls and report them to the Datadog LLM Observability API.

Configure with the following environment variables or Ruby methods:

- `DD_SITE` (optional, default: `datadoghq.com`)
  ```ruby
  Langchain::Datadog.site = 'datadoghq.com'
  ```
  The Datadog site to submit your LLM data.

- `DD_API_KEY` (required)
  ```ruby
  Langchain::Datadog.api_key = '1a2b3c4d5e6f'
  ```
  Your Datadog API key.

- `DD_LLMOBS_ENABLED` (optional, default: `1`)
  ```ruby
  Langchain::Datadog.enabled = true
  ```
  Toggle to disable submitting data to LLM Observability.

- `DD_LLMOBS_ML_APP` (required)
  ```ruby
  Langchain::Datadog.ml_app = 'langchainrb_datadog'
  ```
  The name of your LLM application, service, or project, under which all traces and spans are grouped. This helps distinguish between different applications or experiments.
  See [Application naming guidelines](https://docs.datadoghq.com/llm_observability/setup/api/#application-naming-guidelines) for allowed characters and other constraints.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/GaggleAMP/langchainrb_datadog.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
