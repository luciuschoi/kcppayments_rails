# frozen_string_literal: true

require_relative "lib/kcppayments_rails/version"

Gem::Specification.new do |spec|
  spec.name = "kcppayments_rails"
  spec.version = KcppaymentsRails::VERSION
  spec.authors = ["Lucius Choi"]
  spec.email = ["lucius.choi@gmail.com"]

  spec.summary = "KCP 표준결제 Rails 연동용 엔진과 Stimulus 래퍼"
  spec.description = "Rails 7/8에서 KCP 표준결제를 쉽게 붙일 수 있도록 엔진/헬퍼/제너레이터/Stimulus 컨트롤러를 제공합니다."
  spec.homepage = "https://github.com/luciuschoi/kcppayments_rails"
  spec.required_ruby_version = ">= 3.2.0"

  # spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/luciuschoi/kcppayments_rails"
    spec.metadata["changelog_uri"] = "https://github.com/luciuschoi/kcppayments_rails/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "rails", ">= 7.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
