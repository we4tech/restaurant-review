class PremiumTemplateElementsController < ApplicationController

  def update
    @premium_template_element = PremiumTemplateElement.find(params[:id].to_i)

    data = remove_empty_rows
    data = sort(data)

    if @premium_template_element.update_attribute(:data, data)
      notify :success, :back
    else
      notify :failure, :back
    end
  end

  private
    def sort(data)
      order_key = params[:orderBy]
      if order_key
        data.sort_by{|a| a[order_key].to_i}
      else
        data
      end
    end

    def remove_empty_rows
      empty_check_through = params[:emptyCheckThrough]

      params[:premium_template_element][:data].collect{|i|
        if empty_check_through && !(i[empty_check_through] || '').blank?
          i
        elsif !empty_check_through
          i
        end
      }.compact
    end
end
