Gem::Specification.new do |spec|
  spec.name = "simple_thread_pool"
  spec.version = File.read(File.expand_path("VERSION", __dir__)).strip
  spec.authors = ["Brian Durand"]
  spec.email = ["bbdurand@gmail.com"]

  spec.summary = "Simple thread pool implementation to manage running tasks in parallel."
  spec.homepage = "https://github.com/bdurand/simple_thread_pool"
  spec.license = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  ignore_files = %w[
    .
    Appraisals
    Gemfile
    Gemfile.lock
    Rakefile
    bin/
    gemfiles/
    spec/
  ]
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject { |f| ignore_files.any? { |path| f.start_with?(path) } }
  end

  spec.require_paths = ["lib"]

  spec.add_dependency "redis"

  spec.add_development_dependency "bundler"

  spec.required_ruby_version = ">= 2.5"
end
