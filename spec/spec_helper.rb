require 'active_support'
require 'active_record'
require 'doubleback'

module Doubleback
  module ActiveRecord
    class V2
      def self.dont_call
        raise "Should not be calling #{caller}"
      end
      def self.has_many(name, opts = {}, &extension)
        self.dont_call
      end
      def self.has_one(name, opts = {})
        self.dont_call
      end
      def self.has_and_belongs_to_many(name, opts = {}, &extension)
        self.dont_call
      end
      def self.belongs_to(name, opts = {})
        self.dont_call
      end
    end
    class V3
      def self.dont_call
        raise "Should not be calling #{caller}"
      end
      def self.has_many(name, opts = {}, &extension)
        self.dont_call
      end
      def self.has_one(name, opts = {})
        self.dont_call
      end
      def self.has_and_belongs_to_many(name, opts = {}, &extension)
        self.dont_call
      end
      def self.belongs_to(name, opts = {})
        self.dont_call
      end
    end
  end
end
