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

  $.executeSafe = function(callback) {
    try {
      return callback();
    } catch (exception) {
      alert(exception);
    }
  },

  /**
   * Find existing map instance
   */
  $.fn.mapInstance = function() {
    return App.MapWidget.mInitiatedMaps[this.attr('id')];
  },

  $.fn.markerManager = null,
  $.fn.markersInfo = {},
  $.fn.mMarkers = [],

  $.fn.storeMarkerInfo = function(markerInfo) {
    this.markersInfo[markerInfo.name] = markerInfo;
  },
      
  $.fn.getMarkerInfo = function(markerName) {
    return this.markersInfo[markerName];
  },

  $.fn.mapBuildMarker = function(markerInfo, options) {
    this.storeMarkerInfo(markerInfo);

    var position = new google.maps.LatLng(markerInfo.lat, markerInfo.lng);
    var markerIcon = new google.maps.MarkerImage({
      url: '',
      size: new google.maps.Size(32, 32),
      anchor: new google.maps.Point(5, 32) 
    });

    var clickCallback = options['onclick'];

    var marker = new google.maps.Marker({
      title: markerInfo.name + " (" + markerInfo.reviews_count + ' reviews, ' + markerInfo.reviews_loved + ' loves' + ')',
      icon: markerInfo.marker_icon,
      visible: true,
      position: position,
      map: this.mapInstance(),
      animation: google.maps.Animation.DROP,
      clickable: true
    });

    marker.markerInfo = markerInfo;

    if (clickCallback) {
      google.maps.event.addListener(marker, 'click', function() {
        clickCallback(marker, markerInfo);
      });
    }
    return marker;
  },

  $.fn.clearMarkers = function() {
    for (var i = 0; i < this.mMarkers.length; i++) {
      this.mMarkers[i].setMap(null);
    }
  },

  $.executeLater = function(callback, duration) {
    duration = duration ? duration : 5000;
    setTimeout(callback, duration);
  },

  $.fn.loadNearbyRestaurants = function(pSearchUrl, pHiddenDialogContent, clear) {
    var $this = this;
    $.getJSON(pSearchUrl, function(data){
      if (data) {
        $.executeLater(function() {
          if (clear) {
            //$this.clearMarkers();
          }
          var markers = [];

          for (var i = 0; i < data.length; i++) {
            if (data[i] && $this.getMarkerInfo(data[i].name) == null) {
              markers.push($this.mapBuildMarker(data[i], {
                onclick: function(marker, markerInfo) {
                  pHiddenDialogContent.html(markerInfo.marker_html).dialog({
                    'title': markerInfo.name + " (" + markerInfo.reviews_count + ' reviews, ' + markerInfo.reviews_loved + ' loves' + ')',
                    'width': '600px',
                    'modal': true,
                    'closeOnEscape': true})
                }}));
            }
          }
        }, 1000);
      }
    });
  },

//  #
//  # == What is Levenshtein Distance?
//  # Taken from - http://www.merriampark.com/ld.htm
//  #
//  # Levenshtein distance (LD) is a measure of the similarity between two strings,
//  # which we will refer to as the source string (s) and the target string (t).
//  # The distance is the number of deletions, insertions, or substitutions required
//  # to transform s into t. For example,
//  #
//  #    * If s is "test" and t is "test", then LD(s,t) = 0,
//  #      because no transformations are needed. The strings are already identical.
//  #    * If s is "test" and t is "tent", then LD(s,t) = 1,
//  #      because one substitution (change "s" to "n") is sufficient to transform s into t.
//  #
//  # The greater the Levenshtein distance, the more different the strings are.
//  # Levenshtein distance is named after the Russian scientist Vladimir Levenshtein,
//  # who devised the algorithm in 1965. If you can't spell or pronounce Levenshtein,
//  # the metric is also sometimes called edit distance.
//  # The Levenshtein distance algorithm has been used in:
//  #
//  #    * Spell checking
//  #    * Speech recognition
//  #    * DNA analysis
//  #    * Plagiarism detection
//  #
  $.calculateDistance = function(firstText, secondText, returnMatrix) {
    firstText = firstText.toLowerCase();
    secondText = secondText.toLowerCase();

    var firsTextLength = firstText.length;
    var secondTextLength = secondText.length;
    var matrix = [];

    if (firsTextLength == 0) {
      return secondTextLength;
    }

    if (secondTextLength == 0) {
      return firsTextLength;
    }

    function determineDistance(firstTextLength, secondTextLength) {
      $.debug(matrix);
      return matrix[secondTextLength][firstTextLength];
    }

    function decideMinimumValue(values) {
      var minValue = values[0];
      for (var i = 0; i < values.length; i++) {
        if (values[i] < minValue) {
          minValue = values[i];
        }
      }

      return minValue;
    }

    function compareText(firstTextLength, secondTextLength,
                          firstText, secondText) {
      for (var j = 1; j <= firstTextLength; j++) {
        for (var i = 1; i <= secondTextLength; i++) {
          var n_j = j - 1;
          var m_i = i - 1;

          // If s[i] equals t[j], the cost is 0.
          // If s[i] doesn't equal t[j], the cost is 1.
          var charA = firstText.charAt(n_j);
          var charB = secondText.charAt(m_i);
          var value = charA == charB ? 0 : 1;

          // Set cell d[i,j] of the matrix equal to the minimum of:
          // a. The cell immediately above plus 1: d[i-1,j] + 1.
          var value_1 = matrix[i - 1][j] + 1;
          // b. The cell immediately to the left plus 1: d[i,j-1] + 1.
          var value_2 = matrix[i][j - 1] + 1;
          // c. The cell diagonally above and to the left plus the
          // cost: d[i-1,j-1] + cost.
          var value_3 = matrix[i-1][j-1] + value;
          value = decideMinimumValue([value_1, value_2, value_3]);

          // Set min value
          matrix[i][j] = value
        }
      }
    }

    function prepareMatrix(firstTextLength, secondTextLength) {
      matrix = [];
      for (var i = 0; i <= secondTextLength + 1; i++) {
        matrix[i] = [];
        for (var j = 0; j <= firstTextLength + 1; j++) {
          if (i == 0) {
            matrix[i][j] = j
          } else if (j == 0) {
            matrix[i][j] = i
          }
        }
      }
    }

    prepareMatrix(firsTextLength, secondTextLength);
    compareText(firsTextLength, secondTextLength, firstText, secondText);

    if (returnMatrix) {
      return matrix;
    } else {
      return determineDistance(firsTextLength, secondTextLength);
    }
  },

  $.debug = function(message) {
    // aconsole.debug(message);
  },

  $.visualizeMatrix = function(firstText, secondText) {
    var matrix = $.calculateDistance(firstText, secondText, true);
    var text = "";
    for (var i = 0; i < matrix.length; i++) {
      for (var j = 0; j < matrix[i].length; j++) {
        text += matrix[i][j] + " "
      }
      text += "\n";
    }

    return text;
  },

  /**
   * Iterate through the elements and match more relevant text.
   */
  $.searchRelevantItem = function(text, itemsArray) {
    var mostRelevant = null;

    for (var i = 0; i < itemsArray.length; i++) {
      var values = itemsArray[i];
      var firstText = text;
      var secondText = values[0];
      // Split text based on the minimum textual length
      if (firstText.length > secondText.length) {
        firstText = firstText.substring(0, secondText.length);
      } else {
        secondText = secondText.substring(0, firstText.length);
      }

      var score = $.calculateDistance(firstText, secondText);
      if (mostRelevant == null || score < mostRelevant[0]) {
        mostRelevant = [score, values[0], values[1]];
      }
    }

    $.debug(mostRelevant);
    return mostRelevant;
  },

  $.fuzzySearch = function(text, itemsArray) {
    var mostRelevant = null;

    for (var i = 0; i < itemsArray.length; i++) {
      var values = itemsArray[i];
      var firstText = text;
      var secondText = values[0];
      var score = firstText.score(secondText);
      if (mostRelevant == null || score > mostRelevant[0]) {
        mostRelevant = [score, values[0], values[1]];
      }
    }

    return mostRelevant;
  },

  /**
   * Duplicate and append a specific element's internal HTML to the given element.
   * Ie. if you have an image upload box and you want to add option for "add more" fields.
   * this extension is right for you.
   *
   * @param options an JSON formatted object
   *
   * Allowed options -
   *    duplicate:    - Set duplicable element - jquery object expected
   *    to:           - Set duplicated elements container - jquery object expected
   *
   */
  $.fn.whenClicked = function(options) {
    var $duplicable = options['duplicate'];
    var $container = options['to'];
    var addedCallback = options['added'];

    if ($duplicable && $container) {
      $(this).bind('click', function() {
        $container.append($duplicable.html());
        if (addedCallback) {
          addedCallback($container);
        }
      })
    } else {
      alert('Invalid (whenClicked) usages, please use "duplicate" and "to" attributes');
    }
  }


})(jQuery);

App = {

  mTimer : null
};

App.MapWidget = {

  MAP_INIT : false,
  mMap : null,
  mGeoCoder: null,
  mTextField : null,
  mInitiatedMaps : {},

  Position: function(latLng, address) {
    this.mLatLng = latLng;
    this.mAddress = address;

    this.getLatLng = function() {
      return this.mLatLng;
    };

    this.getAddress = function() {
      return this.mAddress;
    };

    this.address = this.getAddress;

    this.lat = function() { return this.mLatLng.lat() };
    this.lng = function() { return this.mLatLng.lng() };
  },

  createMap: function($pMapWidgetElement, pCallback) {
    if (!$pMapWidgetElement.mapInstance()) {

      var mapOptions = {
        'markerMessage': 'Where is this restaurant located at?',
        'infoWindowMessagePrefix': "Restaurant is located @",
        'mapWidth': '520px',
        'mapHeight': '300px',
        'title': '23.7230556,90.4086111',
        'mapReadOnly': 'false'
      };

      var instanceOptions = {
        zoom: 13,
        mapTypeId: google.maps.MapTypeId.ROADMAP,
        zoomControl: true,
        animation: google.maps.Animation.DROP
      };

      /**
       * Configure map with the attached attributes
       */
      function preConfigureMap() {
        mapOptions = $pMapWidgetElement.extractOptions(
            ['markerMessage', 'infoWindowMessagePrefix',
             'mapWidth', 'mapHeight', 'title', 'mapReadOnly'], mapOptions);

        $pMapWidgetElement.css({
          'width': mapOptions['mapWidth'],
          'height': mapOptions['mapHeight']});

      }

      var mCenter = null;

      /**
       * Set default location from the "title" attribute or use the default one
       */
      function setCenter() {
        var defaultLocation = mapOptions['title'];
        var locationParts = defaultLocation.split(",");
        mCenter = new google.maps.LatLng(locationParts[0], locationParts[1]);
        mMap.setCenter(mCenter, 13);
      }

      /**
       * After creating map object now configure rest of the required configurations
       */
      function postConfigureMap() {
        try {
          //map.setUIToDefault();
          //map.enableGoogleBar();

          setCenter();
        } catch ($e) {
          // alert("Error found while post configuring map - " + $e);
        }
      }

      var marker = null;

      /**
       * Setup a draggable marker to point to the specific location
       */
      function setupDraggableMarker() {
        var markerOptions = {};
        if (mapOptions['mapReadOnly'] == 'false') {
          markerOptions['draggable'] = true;
        }

        markerOptions['position'] = mCenter;
        markerOptions['map'] = mMap;
        markerOptions['title'] = mapOptions['markerMessage']; 

        marker = new google.maps.Marker(markerOptions);
        var infoWindow = new google.maps.InfoWindow({
          content: mapOptions['markerMessage']
        });

        google.maps.event.addListener(marker, 'click', function() {
          infoWindow.open(mMap, marker);
        });


        if (mapOptions['mapReadOnly'] == 'false') {
          google.maps.event.addListener(marker, "dragstart", function() {
            infoWindow.close();
          });

          google.maps.event.addListener(marker, "dragend", function() {
            var position = marker.getPosition();
            var address = null;

            infoWindow.setContent("Retrieving address...");
            infoWindow.open(mMap, marker);

            if (App.MapWidget.mGeoCoder == null) {
              App.MapWidget.mGeoCoder = new google.maps.Geocoder();
            }

            App.MapWidget.mGeoCoder.geocode({'latLng': position}, function(results, status) {
              if (status == google.maps.GeocoderStatus.OK) {
                var location = new App.MapWidget.Position(position, results[1].formatted_address);
                infoWindow.setContent(mapOptions['infoWindowMessagePrefix'] + location.getAddress());
                if (pCallback) {
                  pCallback(location);
                }
              }
            });
          });
        }
      }

      /**
       * If any marker is placed on the map notify the callback closure
       */
      function addEventForAnyMarkerPlacement() {
        if (mapOptions['mapReadOnly'] == 'false') {
          GEvent.addListener(mMap, 'addoverlay', function(pOverlay) {
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
                  if (pCallback) {
                    pCallback(placemark);
                  }
                }
              });
            }
          });
        }
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
        if ($pMapWidgetElement.appear) {
          $pMapWidgetElement.appear();
        }
        //mMap.checkResize();
      }

      var mMap = null;

      /**
       * Create new map instance
       */
      function createInstance() {
        try {
          mMap = new google.maps.Map($pMapWidgetElement[0], instanceOptions);
          App.MapWidget.mInitiatedMaps[$pMapWidgetElement.attr('id')] = mMap;
        } catch ($e) {
          alert("Failed to create map - " + $e);
        }
      }

      var mBrowserSupportFlag = true;
      function detectCurrentPosition() {
        if (!$pMapWidgetElement.isEmptyAttr('detectCurrentPosition') &&
            'true' == $pMapWidgetElement.attr('detectCurrentPosition').toLowerCase()) {
          if (navigator.geolocation) {
            mBrowserSupportFlag = true;
            navigator.geolocation.getCurrentPosition(function(position) {
              var currentLocation = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
              marker.setPosition(currentLocation);
              mMap.setCenter(currentLocation);
            }, function() {
              alert("Couldn't locate your current location");
            });
          }
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
        //setupGlobalEvents();
        detectCurrentPosition();
        appearMap();
      }

      /**
       * Load new map instance
       */
      init();

    }
  }
};

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
};

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
};

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
      $menuPanel.hide();
      $self.removeClass('menuSel');
    } else {
      $menuPanel.css('left', x - 7).css('top', y + $self.css('height') + 10).show();
      $self.removeClass('menuSel').addClass('menuSel');
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
};