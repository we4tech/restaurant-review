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
    // console.debug(message);
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
  }


})(jQuery);

App = {
};

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
};

App.TagSearcher = function(pTextField) {

  var mLastSearchedKey = null;
  var mCachedOptions = [];
  var mTagsPanel = null;
  var mSearchingWorker = null;
  var mDefaultValue = null;

  function indexOptions() {
    mTagsPanel = $('#' + pTextField.attr('title'));
    $('#' + pTextField.attr('title') + ' label').each(function() {
      var $label = $(this);
      var labelId = $label.attr('id');
      if (labelId == null || labelId.length == 0) {
        labelId = ("option_" + Math.random()).replace('.', '');
        $label.attr('id', labelId);
      }

      mCachedOptions.push([$label.html().toLowerCase(), labelId])
    });

    $.debug(mCachedOptions)
  }

  function clearVisualHighlights() {
    $('#' + pTextField.attr('title') + ' label').css('border-bottom', '0');
  }

  function performSearch() {
    if ((mSearchingWorker) != null) {
      clearVisualHighlights();
      clearTimeout(mSearchingWorker);
    }

    mSearchingWorker = setTimeout(function() {
      var text = pTextField.val().trim().toLowerCase();
      if (text.length > 0 && text != mLastSearchedKey) {
        var parts = text.split(",");
        for (var ti = 0; ti < parts.length; ti++) {
          var textPart = parts[ti].trim();
          var mostRelevant = $.fuzzySearch(textPart, mCachedOptions);
          $.debug(mostRelevant);

          if (mostRelevant) {
            var $selectedLabel = $('#' + mostRelevant[2]);
            $selectedLabel.animate({borderBottom: '2px solid red'}, 1000);
            mTagsPanel.scrollTo($selectedLabel, 500);

            if (mostRelevant[1] == textPart) {
              $('#' + $selectedLabel.attr('for')).attr('checked', 'checked');
              pTextField.val('').focus();
            }
          }
        }
      }
    }, 1000);
  }

  function observeKeyPress() {
    pTextField.keyup(function() {
      performSearch()
    });

    pTextField.keypress(function(e) {
      var code = (e.keyCode ? e.keyCode : e.which);
      if(code == 13) {
        return false;
      }
    });
  }

  function clearDefaultMessage() {
    mDefaultValue = pTextField.attr('value');
    pTextField.focus(function() {
      var $this = $(this);
      if (!$this.isEmptyAttr('value') && $this.attr('value') == mDefaultValue) {
        $this.attr('value', '');
      }
    });

    pTextField.blur(function() {
      var $this = $(this);
      if ($this.isEmptyAttr('value')) {
        $this.attr('value', mDefaultValue);
      }
    });
  }

  clearDefaultMessage();
  indexOptions();
  observeKeyPress();

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