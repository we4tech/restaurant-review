String::blank = ->
  @length is 0

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
    if @field.val() is null or @field.val().blank()
      @field.attr 'value', @placeholder
      @field.css 'color', '#888'

#
# Enable a <LI> to turn into a dynamic menu. if sub menu exists show it 
# when user move mouse around.
class Menu
	self = @
	
	constructor: (@el) ->
		@el.addClass 'menu'
		subMenu = @el.children('ul')

		if subMenu.length != 0
			@el.click (e) ->
				subMenu.css 'display', 'block'
				false
				
	

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

SiteFeatures =
	
	# Taken from here - http://javascriptmagic.blogspot.com/2006/09/getting-scrolling-position-using.html
	# Get current scroll position
	getScrollingPosition: ->
	  position = [0, 0];
	  if typeof(window.pageYOffset) != 'undefined'
	    position = [
	      window.pageXOffset,
	      window.pageYOffset
	    ]

	  else if typeof(document.documentElement.scrollTop) != 'undefined' and document.documentElement.scrollTop > 0
	    position = [
	      document.documentElement.scrollLeft,
	      document.documentElement.scrollTop
	    ]

	  else if typeof(document.body.scrollTop) != 'undefined' 
	    position = [
	      document.body.scrollLeft,
	      document.body.scrollTop
	    ]
	   
	  position

	
	# Generate menu item for the each LI element
  setupMenu: (el) ->
    el.children('li').each ->
      new Menu $(@)
      
  showNavigationOnScroll: (el) ->
  	$(document).scroll (e) ->
  		position = SiteFeatures.getScrollingPosition()
  		if position? && position[1] < 8
  			el.show()
  			$('#menuLink').removeClass('on').addClass('on')

  removePlaceholderBeforeSubmittingForm: ->
    $('form').submit (e) ->
      self = $(this)
      self.find('input[placeholder]').each ->
        field = $(this)
        if field.attr('placeholder') is field.attr('value')
          field.attr('value', '')

  detectAutoShowHidePanel: ->
    $('*[toggleView]').each ->
      self = $(this)
      self.click (e) ->
        $('#' + $(e.target).attr('toggleView')).toggle('slide')

HTML5Features.fixFieldsPlaceHolder()
HTML5Features.fixWindowSize()

SiteFeatures.showNavigationOnScroll($('#wrapperSubNav'))
SiteFeatures.removePlaceholderBeforeSubmittingForm()
SiteFeatures.detectAutoShowHidePanel()
