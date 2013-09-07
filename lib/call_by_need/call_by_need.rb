module CallByNeed
  class VarMissingError < StandardError
    def initialize(name, context)
      super("`#{name}` was expected, but doesn't exist in context `#{context.inspect}`.")
    end
  end

  class DuplicateVarError < StandardError
    def initialize(name, context)
      super("`#{name}` can't be initialized twice in context `#{context.inspect}`.")
    end
  end

  def declare(name, &block)
    var_set(name, block)
    class << self; self; end.class_eval do
      define_method(name) do
        get(name)
      end
    end
  end

  def declared?(name)
    store.has_key?(name)
  end

  def get(name)
    unless evaluated?(name)
      store[name] = var_get(name).call(self)
    else
      var_get(name)
    end
  end

  def keys
    store.keys
  end

  def [](key)
    var_get(key)
  end

  def evaluated?(name)
    !var_get(name).respond_to?(:call)
  end

private
  def var_get(name)
    if store.has_key?(name)
      store[name]
    else
      raise VarMissingError.new(name, self)
    end
  end

  def var_set(name, value)
    if store.has_key?(name) && (store[name] != value)
      raise DuplicateVarError.new(name, self)
    else
      store[name] = value # returns value
    end
  end

  def store
    @__store ||= {}
  end
end
