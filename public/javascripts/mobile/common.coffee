String::empty = ->
  this.length is 0

#
# Support place holder for the specified text field
class PlaceholderTextField
  constructor: (@field) ->
    @placeholder = @field.attr 'placeholder'
    @setup()

  setup: ->
    @setPlaceholder()

    @setupEvents()

  setupEvents: ->
    that = @

    @field.bind 'focus', (event) ->
      that.unsetPlaceholder()

    @field.bind 'blur', (event) ->
      that.setPlaceholder()


  unsetPlaceholder: ->
    if @placeholder == @field.val()
      @field.attr 'value', ''
      @field.css 'color', '#000'

  setPlaceholder: ->
    if @field.val() is null or @field.val().empty()
      @field.attr 'value', @placeholder
      @field.css 'color', '#888'


HTML5Features =

  # Generate place holder text if HTML 5 is not enabled
  fixFieldsPlaceHolder: ->
    if !Modernizr.input.placeholder
      $('input[placeholder]').each ->
        new PlaceholderTextField $(this)

    if !Modernizr.inputtypes.search
      $('input[type=search]').addClass('html5_search_field')

  fixWindowSize: ->
    # Do something later alert $(window).width();


HTML5Features.fixFieldsPlaceHolder()
HTML5Features.fixWindowSize()
