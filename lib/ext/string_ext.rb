module StringExt

  def self.included(base)
    base.send :include, InstanceMethods
  end

  module InstanceMethods
    #
    # Remove unwanted sphinx compatible characters
    def sphinxify
      self.parameterize(' ')
    end
  end

end

String.send :include, StringExt