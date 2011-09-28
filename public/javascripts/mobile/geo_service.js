(function() {
  var GeoService;
  GeoService = (function() {
    function GeoService(searchUrl) {
      this.searchUrl = searchUrl;
    }
    GeoService.prototype.findCurrentLocation = function() {
      var dfr;
      dfr = $.Deferred();
      if ((typeof navigator !== "undefined" && navigator !== null) && (navigator.geolocation != null)) {
        navigator.geolocation.getCurrentPosition(function(position) {
          var lat, lng;
          lat = position.coords.latitude;
          lng = position.coords.longitude;
          return dfr.resolve(lat, lng);
        }, function() {
          return dfr.reject();
        });
      }
      return dfr.promise();
    };
    return GeoService;
  })();
  GeoService.searchPlaces = function(searchUrl, lat, lng, meter) {
    if (meter == null) {
      meter = 1000;
    }
    return $.ajax({
      url: searchUrl,
      data: {
        format: 'json',
        limit: 1,
        'fields[]': 'address',
        'excepts[]': ['marker_html', 'description'],
        meter: meter,
        lat: lat,
        lng: lng
      },
      dataTypeString: 'json'
    });
  };
  GeoService.promptUser = function(msg) {
    return $('.siteMessage').each(function() {
      return $(this).html(msg).show();
    });
  };
  GeoService.awareUserAboutNearbyPlaces = function(result, lat, lng, searchUrl) {
    var friendlyAddress, msg;
    searchUrl = searchUrl.replace(/format=json/, 'format=mobile');
    if ((result != null) && result.length > 0) {
      friendlyAddress = result[0].address;
      friendlyAddress = friendlyAddress.split(',')[0];
      msg = "Are you nearby '" + friendlyAddress + "' ?          <div class='quote'>Find your nearby <a href='" + searchUrl + "&meter=1000&lat=" + lat + "&lng=" + lng + "'>Places</a>.</div>          <button type='button' onclick='$(this).parent().hide();'>Close</button>";
      return GeoService.promptUser(msg);
    }
  };
  GeoService.promptNearbySearch = function(searchUrl) {
    var gs;
    gs = new GeoService(searchUrl);
    return gs.findCurrentLocation().then(function(lat, lng) {
      return GeoService.searchPlaces(searchUrl, lat, lng).then(function(r) {
        return GeoService.awareUserAboutNearbyPlaces(r, lat, lng, searchUrl);
      });
    }).fail(function(e) {
      return alert(e);
    });
  };
  window.GeoService = GeoService;
}).call(this);
