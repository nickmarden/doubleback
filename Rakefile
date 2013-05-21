require 'rubygems'
require 'rake'
require 'echoe'

Echoe.new('doubleback', '0.0.1') do |p|
  p.description    = "Write your ActiveRecord associations in AR 4 syntax, but use them in AR 2 and AR 3"
  p.url            = "http://github.com/nickmarden/doubleback"
  p.author         = "Nick Marden"
  p.email          = "nick@marden.org"
  p.ignore_pattern = ["tmp/*", "script/*"]
  p.development_dependencies = []
end

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }
