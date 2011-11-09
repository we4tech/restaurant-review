HTML5Features:

  # Generate place holder text if HTML 5 is not enabled
  fixFieldsPlaceHolder: ->
    if !Modernizr.input.placeholder
      $('input[placeholder=*]').each ->
        alert($(this))


(-> HTML5Features.fixFieldsPlaceHolder())
