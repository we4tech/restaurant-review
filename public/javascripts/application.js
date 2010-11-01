// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
App = {
}

App.MapWidget = {

  MAP_INIT : false,
  mMap : null,
  mGeoCoder: null,
  mTextField : null,

  initMap: function($pMapWidgetElement, pCallback) {
    if (App.MapWidget.mMap == null) {
      $pMapWidgetElement.css('width', '500px').css('height', '300px');

      App.MapWidget.mMap = new GMap2(document.getElementById("google_map_canvas"));

      var map = App.MapWidget.mMap;
      map.setUIToDefault();
      map.enableGoogleBar();

      var center = null;

      var alreadySelectedLocation = $pMapWidgetElement.attr('title');
      if (alreadySelectedLocation == ',') {
        center = new GLatLng(23.7230556, 90.4086111);
      } else {
        var locationParts = alreadySelectedLocation.split(",");
        center = new GLatLng(locationParts[0], locationParts[1]);
      }

      map.setCenter(center, 13);

      var marker = new GMarker(center, {draggable: true});
      marker.openInfoWindowHtml('Where is this restaurant located at?');

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
            marker.openInfoWindowHtml('Restaurant is located @' + placemark.address);
            pCallback(placemark);
          }
        });
      });

      map.addOverlay(marker);

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
              marker.openInfoWindowHtml('Restaurant is located @' + placemark.address);
              pCallback(placemark);
            }
          });
        }
      });

      App.MapWidget.MAP_INIT = true;
      $pMapWidgetElement.appear();
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
});