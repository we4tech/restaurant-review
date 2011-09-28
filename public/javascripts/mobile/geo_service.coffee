#
# Geo service class is used for availing all location specific features
# Including nearby restaurants and so on.
class GeoService

  constructor: (@searchUrl) ->

  findCurrentLocation: ->
    dfr = $.Deferred();

    if navigator? && navigator.geolocation?
      navigator.geolocation.getCurrentPosition (position) ->
        lat = position.coords.latitude
        lng = position.coords.longitude
        dfr.resolve(lat, lng)

      , ->
        dfr.reject()


    dfr.promise()

# Add static methods

#
# Search places by the different query which includes geo data
# Return ajax object
GeoService.searchPlaces = (searchUrl, lat, lng, meter = 1000) ->
  $.ajax
      url: searchUrl
      data:
        format: 'json'
        limit: 1
        'fields[]': 'address'
        'excepts[]': ['marker_html', 'description']
        meter: meter
        lat: lat
        lng: lng

      dataTypeString: 'json'


#
# Show user some message
GeoService.promptUser = (msg) ->
  $('.siteMessage').each ->
    $(this).html(msg).show()

#
# Aware user about nearby places
GeoService.awareUserAboutNearbyPlaces = (result, lat, lng, searchUrl) ->
  searchUrl = searchUrl.replace(/format=json/, 'format=mobile')
  if result? && result.length > 0
    friendlyAddress = result[0].address
    friendlyAddress = friendlyAddress.split(',')[0]
    msg = "Are you nearby '#{friendlyAddress}' ?
          <div class='quote'>Find your nearby <a href='#{searchUrl}&meter=1000&lat=#{lat}&lng=#{lng}'>Places</a>.</div>
          <button type='button' onclick='$(this).parent().hide();'>Close</button>";

    GeoService.promptUser msg

#
# Ask user whether they want to see nearby places or not
# TODO: Make provision for multi language support
GeoService.promptNearbySearch = (searchUrl) ->
  gs = new GeoService searchUrl
  gs.findCurrentLocation()
    .then (lat, lng) ->
      GeoService.searchPlaces(searchUrl, lat, lng)
        .then (r) ->
          GeoService.awareUserAboutNearbyPlaces r, lat, lng, searchUrl

    .fail((e) -> alert e)

# Assign in global scope
window.GeoService = GeoService