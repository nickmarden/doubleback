# Move forward, don't stay in the past

Doubleback allows you to write ActiveRecord 4.x-style association statements
in your models regardless of whether you are using them in ActiveRecord 2.x,
3.x, or 4.x. This flexibility lets you reuse model files across different
versions of Rails - perfect for long-running, incremental upgrade projects.

# How to use

In your Gemfile:

    gem 'doubleback'

In your code

    require 'doubleback'
    ...

    class Community < ActiveRecord::Base
      include Doubleback
      ...

      # Works with ActiveRecord 2.x and 3.x!
      has_many :users, -> { includes(:avatar).where(deleted: false) }, dependent: :destroy

Under ActiveRecord 2.x and 3.x, this ```has_many``` class method call becomes

      has_many :users, :include => [ :avatar ], :conditions => { :deleted => false }, :dependent => :destroy

That's it.

# Ruby version issues

Keep in mind that Ruby-isms such as ```->``` (shorthand for ```proc```) and ```dependent: :destroy```
will not work in Ruby 1.8.x. That's a Ruby language change, not an ActiveRecord compatibility issue.

# Author

Nick Marden, nick@marden.org
