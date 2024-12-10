# frozen_string_literal: true

require_relative 'lib/langchain/datadog/version'

Gem::Specification.new do |spec|
  spec.name = 'langchainrb_datadog'
  spec.version = Langchain::Datadog::VERSION
  spec.authors = ['GaggleAMP', 'Nikolaos Anastopoulos']
  spec.email = ['info@gaggleamp.com', 'ebababi@ebababi.net']

  spec.summary = 'Enables LLM observability with Datadog for Langchain.rb.'
  spec.description = 'Hooks into Langchain.rb methods to capture LLM calls and ' \
                     'report them to the Datadog LLM Observability API.'
  spec.homepage = 'https://github.com/GaggleAMP/langchainrb_datadog'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/GaggleAMP/langchainrb_datadog'
  spec.metadata['github_repo'] = 'git@github.com:GaggleAMP/langchainrb_datadog.git'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'faraday'
  spec.add_dependency 'langchainrb', '>= 0.17.1'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
