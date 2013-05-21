module Doubleback

  MULTI_VALUE_FINDER_METHODS  = [ :includes, :select, :group, :order, :joins, :where, :having, :joins ]
  SINGLE_VALUE_FINDER_METHODS = [ :limit, :offset, :lock, :distinct, :readonly, :from ]
  AR3_REMOVE_FROM_SCOPE       = [ :includes ]

  def self.included(base)

    # !!!!!! EARLY RETURN !!!!!!
    # This module is a null-op for ActiveRecord 4+
    return if ::ActiveRecord::VERSION::MAJOR > 3

    unless [2, 3].include?::ActiveRecord::VERSION::MAJOR 
      raise "Unsupported ActiveRecord version #{::ActiveRecord::VERSION::MAJOR}"
    end

    def base.belongs_to_with_forward_compatibility(name, scope = nil, options = {})
      base.has_many_without_forward_compatibility(
        *([name, Doubleback.merge_activerecord_finder_options(scope, options)].flatten.compact)
      )
    end
    base.alias_method_chain :belongs_to, :forward_compatibility

    def base.has_one_with_forward_compatibility(name, scope = nil, options = {})
      base.has_many_without_forward_compatibility(
        *([name, Doubleback.merge_activerecord_finder_options(scope, options)].flatten.compact)
      )
    end
    base.alias_method_chain :has_one, :forward_compatibility

    def base.has_many_with_forward_compatibility(name, scope = nil, options = {}, &extension)
      base.has_many_without_forward_compatibility(
        *([name, Doubleback.merge_activerecord_finder_options(scope, options), extension].flatten.compact)
      )
    end
    base.alias_method_chain :has_many, :forward_compatibility

    def base.has_and_belongs_to_many_with_forward_compatibility(name, scope = nil, options = {}, &extension)
      base.has_many_without_forward_compatibility(
        *([name, Doubleback.merge_activerecord_finder_options(scope, options), extension].flatten.compact)
      )
    end
    base.alias_method_chain :has_and_belongs_to_many, :forward_compatibility

  end

  def self.merge_activerecord_finder_options(scope = nil, options = {})
    [MULTI_VALUE_FINDER_METHODS + SINGLE_VALUE_FINDER_METHODS].select { |f| options.has_key?(f) }.each do |f|
      raise "Option hash attribute :#{f} deprecated or not allowed in ActiveRecord 4 association syntax"
    end

    # Try calling the scope method if it exists, to record the existence of any
    # chained finder methods within the scope method
    s = ScopeMock.new.call(scope) if scope
    raise "Scope method which return a hash are not supported" if s and s.respond_to?(:has_key?)

    # Now merge the provided options with any finders detected by the scope mock object
    extract =
      if ::ActiveRecord::VERSION::MAJOR == 2
        (MULTI_VALUE_FINDER_METHODS + SINGLE_VALUE_FINDER_METHODS)
      else
        AR3_REMOVE_FROM_SCOPE
      end

    scope_options = extract.inject({}) do |o, f|
      o[self.option_hash_name(f)] = s.send(f) if(s and s.send(f))
      o
    end

    new_scope = 
      if ::ActiveRecord::VERSION::MAJOR == 2 or s.nil?
        nil
      else
        (MULTI_VALUE_FINDER_METHODS + SINGLE_VALUE_FINDER_METHODS).inject(nil) do |p, f|
          if AR3_REMOVE_FROM_SCOPE.include?(f) or s.send(f).empty?
            p
          elsif p.nil?
            proc { send(f, s.send(f)) }
          else
            proc { p.call.send(f, s.send(f)) }
          end
        end
      end

    [ new_scope, options.merge(scope_options) ]

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

    SINGLE_VALUE_FINDER_METHODS.each do |f|
      define_method f do |v|
        instance_variable = "@{#f}"
        if v
          if self.instance_variable_get(instance_variable)
            raise "Can't call #{f} more than once!"
          else
            self.instance_variable_set(instance_variable, v)
          end
        else
          self.instance_variable_get(instance_variable)
        end
      end
    end

    MULTI_VALUE_FINDER_METHODS.each do |f|
      define_method f do |v|
        instance_variable = "@{#f}"
        current_value = self.instance_variable_get(instance_variable)
        if v
          current_value << v
          self.instance_variable_set(instance_variable, current_value.flatten)
        else
          current_value
        end
      end
    end

    def initialize
      SINGLE_VALUE_FINDER_METHODS.each { |f| self.send(f, nil) }
      MULTI_VALUE_FINDER_METHODS.each { |f| self.send(f, [ ] ) }
    end

  end
end
