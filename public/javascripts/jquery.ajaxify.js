(function($) {
  $.fn.ajaxify = function(options) {
    var opts = $.extend($.fn.ajaxify.defaultOptions, options);

    function ajaxifyForm($form) {
      $form.bind('submit', function() {
        var params = $form.serialize();
        var url = $form.attr('action');

        if (opts.format) {
          if (url.indexOf('?') == -1) {
            url += '?format=' + opts.format;
          } else {
            url += '&format=' + opts.format;
          }
        }

        $.ajax({
          url: url,
          'type': $form.attr('method'),
          'data': params,
          dataType: opts.dataType,
          error: function(response) {
            alert("Error - " + response);
          }});
        return false;
      })
    }

    function ajaxifyForms($topElement) {
      $topElement.find('form').each(function() {
        ajaxifyForm($(this))
      });
    }

    return this.each(function() {
      ajaxifyForms($(this));
    })
  },

  $.fn.ajaxify.defaultOptions = {
    format: 'ajax',
    dataType: 'script'
  }
})(jQuery);