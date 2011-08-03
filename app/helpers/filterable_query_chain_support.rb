#
# Add +add_filter+ to the target model thus user can add up multiple
# query with dynamic expression
module FilterableQueryChainSupport

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods

    def enable_filterable_query_chain

    end
  end

  module InstanceMethods

  end

  class ChainableQueryBuilder

    def select(clazz)
    end


  end
end