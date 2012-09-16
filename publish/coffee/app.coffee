require.config({
  baseUrl: 'js'
})

require ['app/router'], (Router) ->
  Router.listen()
  
  $.fn.preload = ->
    this.each( ->
        $('<img/>')[0].src = this
    )
    
  window.validateEmail = (email) ->
    regex = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,4}))$/;
    return regex.test(email)