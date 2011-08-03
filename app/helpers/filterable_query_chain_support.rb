#
# Add +add_filter+ to the target model thus user can add up multiple
# query with dynamic expression
module FilterableQueryChainSupport

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods

    def enable_filterable_query_chain
      # Add +add_filter+ named scope
      self.send :named_scope, :add_filter, lambda { |field, value|
        if field.is_a?(String)
          if field.match(/[><=]$/i)
            {:conditions => ["#{field} ?", value.first]}

          elsif field.match(/\s+IN$/i)
            {:conditions => ["#{field} (?)", value]}

          else
            {:conditions => {field.to_sym, value}}
          end
        else
          {:conditions => {field => value}}
        end
      }

      self.send :include InstanceMethods
    end
  end

  module InstanceMethods

  end

  class ChainableQueryBuilder

    def select(clazz)
    end


  end
end