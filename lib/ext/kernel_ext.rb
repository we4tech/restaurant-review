module KernelExt

  class EmptyClass
    def method_missing(symbol, *args)
      nil
    end
  end

  def if_available? method_name
    object = self.send method_name
    object || EmptyClass.new
  end
end

Object.class_eval do
  include KernelExt
end