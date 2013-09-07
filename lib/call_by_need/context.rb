module CallByNeed
  class Context
    include CallByNeed

    def initialize(*others, &block)
      others.each do |other|
        other.keys.each do |k|
          if other[k].respond_to?(:call)
            declare(k, &other[k])
          else # item has already been evaluated
            declare(k) { other[k] }
          end
        end
      end
      block.call(self) if block
    end

    def merge(*others)
      self.class.new(self, *others)
    end
  end
end
