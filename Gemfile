source 'https://rubygems.org'

ENV['RAILS_VERSION'] ||= '2'

RAILS_VERSION = 
  case ENV['RAILS_VERSION']
  when "2"
    "~> 2.3.13"
  when "3"
    "~> 2.3.13"
  when "4"
    "= 4.0.0rc1"
  else
    raise "Unknown or unsupported Rails version '#{ENV['RAILS_VERSION']}', please specify RAILS_VERSION=<2|3|4> in the environment"
  end

RSPEC_RAILS_VERSION = 
  case ENV['RAILS_VERSION']
  when "2"
    '~> 1.0'
  else
    '~> 2.0'
  end


gem 'rails', RAILS_VERSION
gem "rspec-rails", RSPEC_RAILS_VERSION
