(function() {
  var HTML5Features, PlaceholderTextField;
  String.prototype.empty = function() {
    return this.length === 0;
  };
  PlaceholderTextField = (function() {
    function PlaceholderTextField(field) {
      this.field = field;
      this.placeholder = this.field.attr('placeholder');
      this.setup();
    }
    PlaceholderTextField.prototype.setup = function() {
      this.setPlaceholder();
      return this.setupEvents();
    };
    PlaceholderTextField.prototype.setupEvents = function() {
      var that;
      that = this;
      this.field.bind('focus', function(event) {
        return that.unsetPlaceholder();
      });
      return this.field.bind('blur', function(event) {
        return that.setPlaceholder();
      });
    };
    PlaceholderTextField.prototype.unsetPlaceholder = function() {
      if (this.placeholder === this.field.val()) {
        this.field.attr('value', '');
        return this.field.css('color', '#000');
      }
    };
    PlaceholderTextField.prototype.setPlaceholder = function() {
      if (this.field.val() === null || this.field.val().empty()) {
        this.field.attr('value', this.placeholder);
        return this.field.css('color', '#888');
      }
    };
    return PlaceholderTextField;
  })();
  HTML5Features = {
    fixFieldsPlaceHolder: function() {
      if (!Modernizr.input.placeholder) {
        $('input[placeholder]').each(function() {
          return new PlaceholderTextField($(this));
        });
      }
      if (!Modernizr.inputtypes.search) {
        return $('input[type=search]').addClass('html5_search_field');
      }
    },
    fixWindowSize: function() {}
  };
  HTML5Features.fixFieldsPlaceHolder();
  HTML5Features.fixWindowSize();
}).call(this);
