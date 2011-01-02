(function($) {
  $.fn.ajaxify = function(options) {
    var opts = $.extend($.fn.ajaxify.defaultOptions, options);
    var $this = this;

    function ajaxifyForm($form) {
      $form.bind('submit', function() {
        $form.find('.buttonSubmit').each(function() {
          var $button = $(this);
          $button.removeClass('loading').addClass('loading');
          $button.attr('title', $button.val());
          $button.val('Loading...').attr('disabled', 'disabled');
        });
        return formProcess($form);
      });

      $form.find('.buttonActionSubmitForm').attr('onclick', '').click(function() {
        formProcess($form);
        var $label = $(this).next();
        $label.attr('title', $label.html());
        $label.removeClass('loading').addClass('loading');
        $label.html('Loading...(' + $label.html() + ')');
        $('.buttonActionSubmitForm').attr('disabled', 'disabled');
      });
    }

    function formProcess($form) {
      try {
        var params = $form.serialize();
        var url = $form.attr('action');
        var method = $form.attr('method') || 'GET';

        if (opts.format) {
          // Replace extension
          if (url.indexOf('.html') != -1) {
            url = url.replace(/\.html/, '.' + opts.format);  
          }

          // Add parameter
          if (url.indexOf('?') == -1) {
            url += '?format=' + opts.format;
          } else {
            url += '&format=' + opts.format;
          }
        }

        $.ajax({
          url: url,
          'type': method,
          'data': params,
          dataType: opts.dataType,
          success: function(response) {
            if (opts.urlRef) {
              var parts = window.location.href.split('#!');
              var partsOfPart = parts[0].split('/');
              var urlPartsWithParams = partsOfPart[partsOfPart.length - 1].split('?');
              window.location.href = parts[0] + '#!/' + urlPartsWithParams[0] + '?' + params;
            }

            if (opts.success != null) {
              opts.success(response);  
            }

            if (opts.autoButtonEnable) {
              $form.find('.buttonSubmit').each(function() {
                var $button = $(this);
                $button.removeClass('loading');
                $button.val($button.attr('title')).removeAttr('disabled');
              });
            }
          },
          
          error: function(response) {
            alert("Error - " + response);

            if (opts.autoButtonEnable) {
              $form.find('.buttonSubmit').each(function() {
                var $button = $(this);
                $button.removeClass('loading');
                $button.val($button.attr('title')).removeAttr('disabled');
              });
            }
          }});
      } catch (e) {
        alert(e);
      }

      return false;
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
    dataType: 'script',
    urlRef: true,
    autoButtonEnable: false
  }
})(jQuery);