# namespacing events by layout name
# i.e. "[event].[layout]"
# http://docs.jquery.com/Namespaced_Events
define ->
  class LayoutController
    constructor: ->
      console.log 'initializing layout controller'
    # setup and teardown for all layouts
    setup: (layout) ->
      if this.layouts[layout]?.setup?
        this.layouts[layout].setup()
      return true
    teardown: (layout) ->
      $('body, body *').off(".#{layout}-layout").unbind(".#{layout}-layout")
      if this.layouts[layout]?.teardown?
        this.layouts[layout].teardown()
      return true
    # set up layout-specific setup and teardown. layouts[layout-name]
    layouts:
      static:
        setup: ->
          $('body').bind('new-route.static-layout', (event, req = null) ->
              $("nav#sidebar a:not(##{req.action})").removeClass('selected')
              $("nav#sidebar a##{req.action}").addClass('selected')
          )
          
          require ['app/router'], (Router) ->
            req = Router.getCurrentRequest()
            $('body').trigger('new-route', req)

  unless singleton?
    singleton = new LayoutController()

  return singleton
