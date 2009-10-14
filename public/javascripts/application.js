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

      App.MapWidget.MAP_INIT = true;
      $pMapWidgetElement.appear();
    }
  }
}
