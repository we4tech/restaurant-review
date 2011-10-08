module HomeController::PageUtils

  def self.included(base)
    base.send :include, InstanceMethods
    base.extend ClassMethods
  end

  module ClassMethods
    def configure_cache
      caches_action :frontpage, :index, :most_loved_places,
                    :most_checkedin_places, :recently_reviewed_places,
                    :recent_places, :photos, :cache_path => Proc.new {|c|
        c.cache_path(c)
      }, :if => Proc.new {|c| !c.send(:mobile?)}
    end
  end

  module InstanceMethods
    def allowed_key?(key)
      HomeController::ALLOWED_PARAM_KEY_NEEDLE.each do |needle|
        return true if key.include?(needle)
      end
      false
    end

    private
      def load_paginated_restaurants
        page = params[:page].to_i > 0 ? params[:page].to_i : 1
        joins = ''
        conditions = ''
        @tag_ids.each_with_index do |tag_id, index|
          joins << " LEFT JOIN tag_mappings tm#{index}
                       ON tm#{index}.restaurant_id = restaurants.id
                       AND tm#{index}.topic_id=#{@topic.id}"

          conditions << "tm#{index}.tag_id=#{tag_id}"
          if index < @tag_ids.length - 1
            conditions << ' AND '
          end
        end

        WillPaginate::Collection.create(page, Restaurant.per_page) do |pager|
          pager.replace(Restaurant.all(
                            :conditions => conditions, :joins => joins,
                            :offset => pager.offset, :limit => pager.per_page))

          unless pager.total_entries
            pager.total_entries = Restaurant.count(
                :conditions => conditions, :joins => joins)
          end
        end
      end
  end
end
