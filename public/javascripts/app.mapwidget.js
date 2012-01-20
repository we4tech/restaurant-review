App.MapWidget = {

  MAP_INIT : false,
  mMap : null,
  mGeoCoder: null,
  mTextField : null,
  mInitiatedMaps : {},

  getGeoCoder: function() {
    if (App.MapWidget.mGeoCoder == null) {
      App.MapWidget.mGeoCoder = new google.maps.Geocoder();
    }

    return App.MapWidget.mGeoCoder;
  },

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
    this.area = function() {
      if (this.mAddress) {
        var parts = this.mAddress.split(',');
        if (parts.length > 0) {
          return parts[0].trim();
        }
      }
      return null;
    };

    this.lat = function() {
      return this.mLatLng.lat()
    };
    this.lng = function() {
      return this.mLatLng.lng()
    };
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

        if (marker == null) {
          marker = new google.maps.Marker(markerOptions);
        }

        if (marker.mInfoWindow == null) {
          marker.mInfoWindow = new google.maps.InfoWindow({
            content: mapOptions['markerMessage']
          });
        }

        google.maps.event.addListener(marker, 'click', function() {
          marker.mInfoWindow.open(mMap, marker);
        });

        if (mapOptions['mapReadOnly'] == 'false') {
          google.maps.event.addListener(marker, "dragstart", function() {
            marker.mInfoWindow.close();
          });

          google.maps.event.addListener(mMap, 'dragend', function() {
            marker.setPosition(mMap.getCenter());
            loadLocationDetails(marker);
          });

          google.maps.event.addListener(mMap, 'dragstart', function() {
            marker.mInfoWindow.close();
          });

          google.maps.event.addListener(mMap, 'drag', function() {
            marker.setPosition(mMap.getCenter());
          });

          google.maps.event.addListener(mMap, 'zoom_changed', function() {
            mMap.panTo(mCenter);
          });

          google.maps.event.addListener(marker, "dragend", function() {
            loadLocationDetails(marker);
          });
        }
      }

      function loadLocationDetails(marker) {
        var position = marker.getPosition();
        var address = null;

        marker.mInfoWindow.setContent("Retrieving address...");
        marker.mInfoWindow.open(mMap, marker);

        App.MapWidget.getGeoCoder().geocode({'latLng': position}, function(results, status) {
          if (status == google.maps.GeocoderStatus.OK) {
            var location = new App.MapWidget.Position(position, results[1].formatted_address);
            marker.mInfoWindow.setContent(mapOptions['infoWindowMessagePrefix'] + location.getAddress());
            if (pCallback) {
              pCallback(location);
            }
          }
        });
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

              App.MapWidget.getGeoCoder().geocode({'latLng': place}, function(results, status) {
                if (status == google.maps.GeocoderStatus.OK) {
                  if (results[1]) {
                    marker.openInfoWindowHtml(mapOptions['infoWindowMessagePrefix'] + results[1].formatted_address);
                  }
                  if (pCallback) {
                    var location = new App.MapWidget.Position(place, results[1].formatted_address);
                    pCallback(location);
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

      function detectCurrentPosition(forced) {
        var currPositionDetectAttributeFound = !$pMapWidgetElement.isEmptyAttr('detectCurrentPosition') &&
            'true' == $pMapWidgetElement.attr('detectCurrentPosition').toLowerCase();

        if (forced || currPositionDetectAttributeFound) {
          if (navigator.geolocation) {
            mBrowserSupportFlag = true;
            navigator.geolocation.getCurrentPosition(function(position) {
              var currentLocation = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
              marker.setPosition(currentLocation);
              mMap.setCenter(currentLocation);

              App.MapWidget.getGeoCoder().geocode({'latLng': currentLocation}, function(results, status) {
                if (status == google.maps.GeocoderStatus.OK) {
                  if (results[1]) {
                    if (marker.mInfoWindow) {
                      marker.mInfoWindow.setContent(mapOptions['infoWindowMessagePrefix'] + results[1].formatted_address);
                    }

                  }

                  if (pCallback) {
                    var location = new App.MapWidget.Position(currentLocation, results[1].formatted_address);
                    pCallback(location);
                  }
                }
              });
            }, function() {
              alert("Couldn't locate your current location");
            });
          }
        }
      }

      function retrieveCurrentGeoLocation() {
        if (marker) {

          if (marker.mInfoWindow == null) {
            marker.mInfoWindow = new google.maps.InfoWindow({
              content: mapOptions['markerMessage']
            });
          }

          marker.mInfoWindow.setContent('Retrieving address...');
          marker.mInfoWindow.open(mMap, marker);

          App.MapWidget.getGeoCoder().geocode({'latLng': marker.getPosition()}, function(results, status) {
            if (status == google.maps.GeocoderStatus.OK) {
              if (results[1]) {
                marker.mInfoWindow.setContent(mapOptions['infoWindowMessagePrefix'] + results[1].formatted_address);
              }

              if (pCallback) {
                var location = new App.MapWidget.Position(marker.getPosition(), results[1].formatted_address);
                pCallback(location);
              }
            }
          });
        }
      }

      var $searchField = null;
      var autoComplete = null;
      var service = null;

      function addSearchField() {
        var searchFieldId = $pMapWidgetElement.attr('id') + '_search_field';
        $searchField = $('<input type="search" id="' + searchFieldId + '" placeholder="Search address..." class="google_map_search_field"/>');
        $pMapWidgetElement.before($searchField);

        var options = {
          bounds: mMap.getBounds()
        };
        autoComplete = new google.maps.places.Autocomplete($searchField[0]);
        google.maps.event.addListener(mMap, 'bounds_changed', function() {
          autoComplete.setBounds(mMap.getBounds());
        });

        var placeholderText = 'Search address...';
        $searchField.val(placeholderText);
        $searchField.focus(function() {
          var $this = $(this);
          if ($this.val() == placeholderText) {
            $this.val('');
          }
        });

        $searchField.blur(function() {
          var $this = $(this);
          if ($this.val() && $this.val().length == 0) {
            $this.val(placeholderText);
          }
        });

        $searchField.keypress(function(e) {
          return e.keyCode != 13;
        });

        google.maps.event.addListener(autoComplete, 'place_changed', function() {
          var place = autoComplete.getPlace();
          if (place.geometry.viewport) {
            mMap.fitBounds(place.geometry.viewport);
          } else {
            mMap.setCenter(place.geometry.location);
            mMap.setZoom(17);
          }
          marker.setPosition(place.geometry.location);

          if (marker.mInfoWindow == null) {
            marker.mInfoWindow = new google.maps.InfoWindow({
              content: mapOptions['markerMessage']
            });
          }
          marker.mInfoWindow.setContent(mapOptions['infoWindowMessagePrefix'] + place.formatted_address);
          marker.mInfoWindow.open(mMap, marker);

          if (pCallback) {
            var location = new App.MapWidget.Position(place.geometry.location, place.formatted_address);
            pCallback(location);
          }
        });
      }

      function addReDetectField() {
        var searchFieldId = $pMapWidgetElement.attr('id') + '_search_field';
        var $detectButton = $('<input type="button" class="icon_current_location" value="DL" title="Detect current location"/>');
        $('#' + searchFieldId).after($detectButton);

        $detectButton.click(function(e) {
          detectCurrentPosition(true);
        });
      }

      function addFullView() {
//        var $fullViewButton = $('<input type="button" value="Full screen"/>');
//        $pMapWidgetElement.before($fullViewButton);
//
//        $fullViewButton.click(function(e) {
//          $pMapWidgetElement.css({'width': '100%', 'height': '100%'});
//        });
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
        retrieveCurrentGeoLocation();
        appearMap();
        addSearchField();
        addReDetectField();
        addFullView();
      }

      /**
       * Load new map instance
       */
      init();

    }
  }
};