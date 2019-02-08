Gem::Specification.new do |spec|
  spec.name          = "simple_thread_pool"
  spec.version       = File.read(File.expand_path("VERSION", __dir__)).chomp
  spec.authors       = ["Brian Durand"]
  spec.email         = ["bbdurand@gmail.com"]

  spec.summary       = %q{Simple thread pool implementation to manage running tasks in parallel.}
  spec.homepage      = "https://github.com/bdurand/simple_thread_pool"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.8"
end
