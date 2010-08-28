module PremiumTemplateElementsHelper

  def pte_text_field(key, element_item = {}, default_value = nil)
    text_field_tag(pte_field_name(key), element_item ? element_item[key] : default_value)
  end

  def pte_text_area(key, element_item = {}, default_value = nil)
    text_area_tag(pte_field_name(key), element_item ? element_item[key] : default_value)
  end

  def pte_field_name(key)
    "premium_template_element[data][][#{key.to_s}]"
  end
end
