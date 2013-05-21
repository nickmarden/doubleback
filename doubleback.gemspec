# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "doubleback"
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Nick Marden"]
  s.date = "2013-05-21"
  s.description = "Write your ActiveRecord associations in AR 4 syntax, but use them in AR 2 and AR 3"
  s.email = "nick@marden.org"
  s.extra_rdoc_files = ["README.rdoc", "lib/doubleback.rb"]
  s.files = ["Gemfile", "README.rdoc", "lib/doubleback.rb", "Manifest", "doubleback.gemspec", "Rakefile"]
  s.homepage = "http://github.com/nickmarden/doubleback"
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Doubleback", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "doubleback"
  s.rubygems_version = "1.8.24"
  s.summary = "Write your ActiveRecord associations in AR 4 syntax, but use them in AR 2 and AR 3"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
