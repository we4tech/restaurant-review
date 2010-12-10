module AjaxFragmentHelper

  # taken from - http://stackoverflow.com/questions/339130/how-do-i-render-a-partial-of-a-different-format-in-rails
  def with_format(format, &block)
    old_format       = @template_format
    @template_format = format
    result           = block.call
    @template_format = old_format
    result
  end

end
