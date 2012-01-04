module TagGroupsHelper

  def render_tags_by_group(tags)
    #.collect { |tag| link_to(tag.name, section_url(tag, true)) }.join(', ')
    grouped_tags = ActiveSupport::OrderedHash.new
    default_group = :none

    tags.each do |tag|
      group = tag.tag_groups.first
      key = group ? group : default_group

      grouped_tags[key] ||= []
      grouped_tags[key] << tag
    end

    content_tag('div', :class => 'groupedTags') do
      html = ''
      grouped_tags.each do |group, _tags|
        group_name = group != :none ? "#{group.name}: " : 'Others'
        html << content_tag('div', :class => 'tagGroup') do
          tag_html = content_tag('strong', group_name)
          tag_html << content_tag('div', _tags.collect{|t| link_to(t.name, section_url(t, true))}.join(', '))
          tag_html
        end
      end

      html
    end
  end
end
