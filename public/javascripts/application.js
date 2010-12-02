// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// JQuery utility extension
(function($) {

  /**
   * Check whether the specific attribute is empty
   * @param attributeKey attribute key
   */
  $.fn.isEmptyAttr = function(attributeKey) {
    return (!this.attr(attributeKey) || this.attr(attributeKey).length == 0)
  },

  /**
   * Extract options from the specified dom element's attribute if not exists default will be returned
   * ++ Warning the passed options will be modified
   * @param attributeKeys List of optionalize keys
   */
  $.fn.extractOptions = function(attributeKeys, options) {

    for (var i = 0; i < attributeKeys.length; i++) {
      var attributeKey = attributeKeys[i];
      if (!this.isEmptyAttr(attributeKey)) {
        options[attributeKey] = this.attr(attributeKey);
      }
    }

    return options;
  },

  /**
   * Find existing map instance
   */
  $.fn.mapInstance = function() {
    return App.MapWidget.mInitiatedMaps[this.attr('id')];
  }


})(jQuery);

App = {
}

App.MapWidget = {

  MAP_INIT : false,
  mMap : null,
  mGeoCoder: null,
  mTextField : null,
  mInitiatedMaps : {},

  createMap: function($pMapWidgetElement, pCallback) {
    if (!$pMapWidgetElement.mapInstance()) {

      var mapOptions = {
        'markerMessage': 'Where is this restaurant located at?',
        'infoWindowMessagePrefix': "Restaurant is located @",
        'mapWidth': '520px',
        'mapHeight': '300px',
        'title': '23.7230556,90.4086111'
      };

      /**
       * Configure map with the attached attributes
       */
      function preConfigureMap() {
        mapOptions = $pMapWidgetElement.extractOptions(
            ['markerMessage', 'infoWindowMessagePrefix',
             'mapWidth', 'mapHeight', 'title'], mapOptions);

        $pMapWidgetElement.css({
          'width': mapOptions['mapWidth'],
          'height': mapOptions['mapHeight']});

      }

      var center = null;

      /**
       * Set default location from the "title" attribute or use the default one
       */
      function setCenter() {
        var defaultLocation = mapOptions['title'];
        var locationParts = defaultLocation.split(",");
        center = new GLatLng(locationParts[0], locationParts[1]);
        map.setCenter(center, 13);
      }

      /**
       * After creating map object now configure rest of the required configurations
       */
      function postConfigureMap() {
        try {
          map.setUIToDefault();
          map.enableGoogleBar();

          setCenter();
        } catch ($e) {
          alert("Error found while post configuring map - " + $e);
        }
      }

      var marker = null;

      /**
       * Setup a draggable marker to point to the specific location
       */
      function setupDraggableMarker() {
        marker = new GMarker(center, {draggable: true});
        map.addOverlay(marker);
        marker.openInfoWindowHtml(mapOptions['markerMessage']);

        GEvent.addListener(marker, "dragstart", function() {
          map.closeInfoWindow();
        });

        GEvent.addListener(marker, "dragend", function() {
          var place = marker.getLatLng();
          var address = null;
          marker.openInfoWindowHtml("Retrieving address...");
          if (App.MapWidget.mGeoCoder == null) {
            App.MapWidget.mGeoCoder = new GClientGeocoder();
          }

          App.MapWidget.mGeoCoder.getLocations(place, function(response) {
            if (response || response.Status.code == 200) {
              var placemark = response.Placemark[0];
              marker.openInfoWindowHtml(mapOptions['infoWindowMessagePrefix'] + placemark.address);
              pCallback(placemark);
            }
          });
        });


      }

      /**
       * If any marker is placed on the map notify the callback closure
       */
      function addEventForAnyMarkerPlacement() {
        GEvent.addListener(map, 'addoverlay', function(pOverlay) {
          if (pOverlay instanceof GMarker) {
            var place = pOverlay.getLatLng();
            marker.setLatLng(place);

            pOverlay.closeInfoWindow();

            var address = null;
            marker.openInfoWindowHtml("Retrieving address...");
            if (App.MapWidget.mGeoCoder == null) {
              App.MapWidget.mGeoCoder = new GClientGeocoder();
            }

            App.MapWidget.mGeoCoder.getLocations(place, function(response) {
              if (response || response.Status.code == 200) {
                var placemark = response.Placemark[0];
                marker.openInfoWindowHtml(mapOptions['infoWindowMessagePrefix'] + placemark.address);
                pCallback(placemark);
              }
            });
          }
        });
      }

      /**
       * Setup all global events
       */
      function setupGlobalEvents() {
        addEventForAnyMarkerPlacement();
      }

      /**
       * Appear map object
       */
      function appearMap() {
        $pMapWidgetElement.appear();
        map.checkResize();
      }

      var map = null;

      /**
       * Create new map instance
       */
      function createInstance() {
        try {
          map = new GMap2(document.getElementById($pMapWidgetElement.attr('id')));
          App.MapWidget.mInitiatedMaps[$pMapWidgetElement.attr('id')] = map;
        } catch ($e) {
          alert("Failed to create map - " + $e);
        }
      }

      /**
       * Initiate new map object and register in global scope
       */
      function init() {
        preConfigureMap();
        createInstance();
        postConfigureMap();
        setupDraggableMarker();
        setupGlobalEvents();
        appearMap();
      }

      /**
       * Load new map instance
       */
      init();

    }
  }
}


App.UI = {

  detectFieldWithDefaultValue: function(pDefaultText, pClass, pPasswordField) {
    var defaultText = pDefaultText;
    var lClass = pClass == null ? 'fieldWithDefaultValue' : pClass;

    $('input.' + lClass).each(function() {

      if (pPasswordField) {
        $(this)[0].type = 'text';
      }

      if ($(this).val() != defaultText) {
        $(this).val(defaultText);
      }

      $(this).bind('focus', function() {
        var $self = $(this);
        if ($self.val() == defaultText) {
          $self.val('');
          $self.removeClass('fieldWithDefaultValue').addClass('fieldSelected');
          if (pPasswordField) {
            $self[0].type = 'password';
          }
        }
      });

      $(this).bind('blur', function() {
        var $self = $(this);
        if ($self.val() == '') {
          $self.val(defaultText);
          $self.removeClass('fieldSelected').addClass('fieldWithDefaultValue');
          if (pPasswordField) {
            $self[0].type = 'text';
          }
        }
      });
    });
  }
}

/**
 * Lookup for all "adminPortionActivationLink" links if current browser url
 * contains '#ref-string'
 *
 * Ie. http://..../products/1#adminPortion
 * it will match all links which has the same class name and link if not
 * visible it will be appeared visible.
 */
$(function() {
  var currentLocation = window.location.href;
  var adminPortionVisible = false;
  var dialog = null;

  if (currentLocation.indexOf('#') != -1 &&
      currentLocation.indexOf('#!') == -1) {

    var parts = currentLocation.split('#');
    if (parts.length > 1 && parts[1].length > 0) {
      //$('.' + parts[1]).show();
      dialog = $('.' + parts[1]).dialog({
        'title': $('.' + parts[1] + 'ActivationLink').attr('title'),
        'modal': true,
        'closeOnEscape': true,
        'width': 'auto',
        'close': function() {
          $('.' + parts[1] + 'ActivationLink').toggle();
          window.location = window.location.href.split('#')[0] + '#';
        }
      });

      adminPortionVisible = true;
      $('.' + parts[1] + 'ActivationLink').toggle();
    }
  } else if (currentLocation.indexOf('#!') != -1) {
    var parts = currentLocation.split('#!');
    window.location.href = "http://" + window.location.host + parts[1];
  }

  $('.adminPortionActivationLink').click(function() {
    $('.' + $(this).attr('class')).toggle();

    if (dialog == null) {
      dialog = $('.adminPortion').dialog({
        'title': $(this).attr('title'),
        'modal': true,
        'closeOnEscape': true,
        'width': 'auto',
        'close': function() {
          $('.' + $(this).attr('class')).toggle();
          window.location = window.location.href.split('#')[0] + '#';
        }
      });
    } else {
      $('.adminPortion').dialog('open');
    }
  });
});

/**
 * Optimized slider, it caches next (2 x displayed pictures) so user gets
 * more flexible image sliding experience.
 */
var SliderCacheUtil = {
  _CACHES : {},

  addCache: function(key, value) {
    SliderCacheUtil._CACHES[key] = value;
  },

  addItemsToCache: function(key, items) {
    var cachedItems = SliderCacheUtil.getCache(key);
    if (cachedItems != null) {
      for (var i = 0; i < items.length; i++) {
        cachedItems[cachedItems.length] = items[i];
      }
    }
  },

  getCache: function(key) {
    return SliderCacheUtil._CACHES[key];
  },

  getCachedItemsAt: function(index, key) {
    var items = SliderCacheUtil.getCache(key);
    return items[index];
  },

  removeCache: function(key) {
    SliderCacheUtil._CACHES[key] = null;
  },

  syncCache: function(key, current_position, url) {
    var items = SliderCacheUtil.getCache(key);
    if (items != null && items.length > 0) {
      if ((items.length - current_position) < 3) {
        $.getScript(url);
      }
    }
  }
}

$(function() {
  $('.message').css('cursor', 'pointer').click(function() {
    $(this).fadeOut().remove();
  });

  $('.pagination a').each(function() {
    $(this).attr('href', $(this).attr('href') + '#adminPortion');
  });

  $('.submenu').click(function() {
    var $menuPanel = $($(this).attr('rev'));
    var $self = $(this);
    var x = $self.offset().left;
    var y = $self.offset().top;
    if ($menuPanel.css('display') == 'block' || $menuPanel.css('display') == 'inline') {
      $menuPanel.slideUp(function() {
        $(this).hide();
        $self.removeClass('menuSel');
      })
    } else {
      $self.removeClass('menuSel').addClass('menuSel');
      $menuPanel.css('left', x - 7).css('top', y + $self.css('height') + 10).slideDown();
    }
  });
});

App.Tasks = {
  tasks : [],

  addTask: function(closure) {
    App.Tasks.tasks.push(closure)
  },

  executeTasks : function() {
    for (var i = 0; i < App.Tasks.tasks.length; i++) {
      App.Tasks.tasks[i].call();
    }
  }
}