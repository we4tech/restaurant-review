(function() {
  var HTML5Features, Menu, PlaceholderTextField, SiteFeatures;
  String.prototype.blank = function() {
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
      if (this.field.val() === null || this.field.val().blank()) {
        this.field.attr('value', this.placeholder);
        return this.field.css('color', '#888');
      }
    };
    return PlaceholderTextField;
  })();
  Menu = (function() {
    var self;
    self = Menu;
    function Menu(el) {
      var subMenu;
      this.el = el;
      this.el.addClass('menu');
      subMenu = this.el.children('ul');
      if (subMenu.length !== 0) {
        this.el.click(function(e) {
          subMenu.css('display', 'block');
          return false;
        });
      }
    }
    return Menu;
  })();
  HTML5Features = {
    fixFieldsPlaceHolder: function() {
      if (!Modernizr.input.placeholder) {
        $('input[placeholder], textarea[placeholder]').each(function() {
          return new PlaceholderTextField($(this));
        });
      }
      if (!Modernizr.inputtypes.search) {
        return $('input[type=search]').addClass('html5_search_field');
      }
    },
    fixWindowSize: function() {}
  };
  SiteFeatures = {
    getScrollingPosition: function() {
      var position;
      position = [0, 0];
      if (typeof window.pageYOffset !== 'undefined') {
        position = [window.pageXOffset, window.pageYOffset];
      } else if (typeof document.documentElement.scrollTop !== 'undefined' && document.documentElement.scrollTop > 0) {
        position = [document.documentElement.scrollLeft, document.documentElement.scrollTop];
      } else if (typeof document.body.scrollTop !== 'undefined') {
        position = [document.body.scrollLeft, document.body.scrollTop];
      }
      return position;
    },
    setupMenu: function(el) {
      return el.children('li').each(function() {
        return new Menu($(this));
      });
    },
    showNavigationOnScroll: function(el) {
      return $(document).scroll(function(e) {
        var position;
        position = SiteFeatures.getScrollingPosition();
        if ((position != null) && position[1] < 8) {
          el.show();
          return $('#menuLink').removeClass('on').addClass('on');
        }
      });
    },
    removePlaceholderBeforeSubmittingForm: function() {
      return $('form').submit(function(e) {
        var self;
        self = $(this);
        return self.find('input[placeholder]').each(function() {
          var field;
          field = $(this);
          if (field.attr('placeholder') === field.attr('value')) {
            return field.attr('value', '');
          }
        });
      });
    },
    detectAutoShowHidePanel: function() {
      return $('*[toggleView]').each(function() {
        var self;
        self = $(this);
        return self.click(function(e) {
          return $('#' + $(e.target).attr('toggleView')).toggle(500, 'easeInOutBounce');
        });
      });
    },
    setDefaultHook: function() {
      return $(window).click(function(e) {
        return $('.siteMessage').hide();
      });
    }
  };
  HTML5Features.fixFieldsPlaceHolder();
  HTML5Features.fixWindowSize();
  SiteFeatures.removePlaceholderBeforeSubmittingForm();
  SiteFeatures.detectAutoShowHidePanel();
  SiteFeatures.setDefaultHook();
}).call(this);
