require 'active_support/version'
require 'active_support/basic_object'
require 'active_support/core_ext'

module Doubleback
  mattr_accessor :major_version
  major_version = ::ActiveRecord::VERSION::MAJOR
  mattr_accessor :minor_version
  minor_version = ::ActiveRecord::VERSION::MINOR

  MULTI_VALUE_FINDER_METHODS  = [ :includes, :select, :group, :order, :joins, :where, :having, :joins ]
  SINGLE_VALUE_FINDER_METHODS = [ :limit, :offset, :lock, :distinct, :readonly, :from ]
  MAPPED_METHODS              = {
    :belongs_to              => false,
    :has_one                 => false,
    :has_many                => true,
    :has_and_belongs_to_many => true,
  }

  def self.included(base)

    # !!!!!! EARLY RETURN !!!!!!
    # This module is a null-op for ActiveRecord 4+
    return if Doubleback.major_version > 3

    unless [2, 3].include? Doubleback.major_version
      raise "Unsupported ActiveRecord version #{Doubleback.major_version}"
    end

    class << base

      MAPPED_METHODS.each do |assoc, allows_extension|

        define_method("#{assoc}_with_forward_compatibility") do |name, *args, &extension|

          # Only has*many allow blocks
          raise "#{assoc} does not allow an extension block" if(extension and not allows_extension)

          scope, options =
            if args.empty?
              [ nil, { } ]
            elsif args.size == 1
              if args[0].respond_to?(:has_key?)
                [ nil, args.shift ]
              elsif args[0].is_a?(Proc)
                [ args.shift, { } ]
              end
            else
              [ args.shift, args.shift ]
            end

          raise "#{assoc}(name, scope = nil, options = {}#{allows_extension ? ', &extension': ''})" unless args.empty?

          # Send the version-appropriate arguments to the actual version-specific association method
          new_options = Doubleback.merge_activerecord_finder_options(scope, options)
          if extension
            send("#{assoc}_without_forward_compatibility".to_sym, name, new_options, &extension)
          else
            send("#{assoc}_without_forward_compatibility".to_sym, name, new_options)
          end
        end
        alias_method_chain assoc, :forward_compatibility
      end
    end
  end

  def self.merge_activerecord_finder_options(scope = nil, options = {})
    [MULTI_VALUE_FINDER_METHODS + SINGLE_VALUE_FINDER_METHODS].select { |f| options.has_key?(f) }.each do |f|
      raise "Option hash attribute :#{f} deprecated or not allowed in ActiveRecord 4 association syntax"
    end

    # Try calling the scope method if it exists, to record the existence of any
    # chained finder methods within the scope method
    s = ScopeMock.new.instance_eval(&scope) if scope
    raise "Scope methods which return a hash are not supported" if s and s.respond_to?(:has_key?)

    scope_options = (MULTI_VALUE_FINDER_METHODS + SINGLE_VALUE_FINDER_METHODS).inject({}) do |o, f|
      o[self.option_hash_name(f)] = s.send(f) if(s and s.send(f).present?)
      o
    end

    options.merge(scope_options)

  end

  def self.option_hash_name(key)
    if key == :includes
      :include
    elsif [ :where, :having ].include?(key)
      :conditions
    else
      key
    end
  end

  class ScopeMock

    SINGLE_VALUE_FINDER_METHODS.each do |field|
      f = "@#{field}"
      define_method field do |*args|
        v = args.shift if args.size > 0
        if v
          if self.instance_variable_get(f)
            raise "Can't call #{f} more than once!"
          else
            self.instance_variable_set(f, v)
            self
          end
        else
          self.instance_variable_get(f)
        end
      end
    end

    MULTI_VALUE_FINDER_METHODS.each do |field|
      f = "@#{field}"
      define_method field do |*args|
        v = args.shift if args.size > 0
        current_value = self.instance_variable_get(f) || [ ]
        if v
          current_value << v
          self.instance_variable_set(f, current_value.flatten)
          self
        else
          current_value
        end
      end
    end

  end
end
