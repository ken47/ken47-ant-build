define 'app/controllers/static_controller', ['app/app_view','app/app_services'], (AppView,AppServices) ->
  class StaticController
    default_layout: 'static'
    current_action: null
    beforeInvoke: ->
    afterInvoke: ->
    invoke: (req) ->
      self = this

      if this.current_action?
        $('body').off(".#{req.ctrl}-#{this.current_action}")
        if this[this.current_action]['teardown']?
          this[this.current_action]['teardown']()

      this[req.action]['setup']() if this[req.action]['setup']?
      $("nav#sidebar a:not(##{req.action})").removeClass('selected')
      $("nav#sidebar a##{req.action}").addClass('selected')
      
      if this[req.action]['view_models']?
        $.each(this[req.action]['view_models'], (container_id,params) ->
          AppServices.applyBindings(req,container_id,params)
        )
      this.afterInvoke()
    about:
      title: 'About Lyfe'
      dom_ready: ->
        $('body').css('background','url(../img/controllers/static/body-bg.png)')
      view_models:
        main:
          endpoint: 'js/data/static/about.json'
    team:
      title: 'The Team'
      view_models:
        main:
          endpoint: 'js/data/static/team.json'
    splash:
      title: 'Welcome to Lyfe'
      layout: 'empty'
      main_container_selector: '#empty'
      setup: ->
        require ['parabolasel'], (parabolasel) ->
          parabolasel.init()
        
        $('body').on('click.static-splash', '#close-popup', ->
          popupOnClick()
        )
      
        generateFlashNotice = (error) ->
          $("#popup").append "<div class='form-element error'>" + error + "</div>"
      
        clearFlashNotice = ->
          $("#popup").find(".error").remove()
      
        $('body').on('click.static-splash', '#request-invite', (event) ->
          event.preventDefault()
          self = this
          clearFlashNotice()
          if not window.validateEmail($("#email-input").val())
            generateFlashNotice "This email is invalid"
            $("#email-input").parent().effect("shake", {
              times: 3
              distance: 7
            }, 100)
            return false
          $(this).parent().find("input").attr "disabled", "disabled"
          $('body').off('click.static-splash',this)
          # $(this).unbind("click").attr "disabled", "disabled"
          $(this).attr "disabled", "disabled"
          window.setTimeout(->
            $(self).html "Request Sent"
            generateFlashNotice "Request submitted!"
            window.setTimeout(->
              popupOnClick()
            , 2000)
          , 500)
        )
      
        popupOnClick = ->
          # $("#get-the-app").unbind "click"
          $('body').off('click.static-splash','#get-the-app')
          if $("#popup").css("display") is "none"
            $("#popup").css("z-index", 100000).fadeIn("slow", ->
              $('body').on('click.static-splash','#get-the-app', ->
                popupOnClick()
              )
            )
          else
            $("#popup").fadeOut "slow", ->
              $("#popup").css "zcall-index", -1
              # $("#get-the-app").click ->
              $('body').on('click.static-splash','#get-the-app', ->
                popupOnClick()
              )
      
        $('body').on('click.static-splash','#get-the-app', ->
          popupOnClick()
        )
      
        $dynamic_bg = $("#static-splash #dynamic-background")
        # bg_ratio = 1.6
        $dynamic_bg.css("min-height": $("#main").height()).height 1200  if window.is_mobile
        
        $(window).bind('resize.static-splash', ->
          $dynamic_bg.height $(window).height()
          $("#main").height $(window).height()
          $dynamic_bg.width $(window).width()
        )
        
        if window.is_mobile
          $dynamic_bg.css({
            'min-height': $('#main').height(),
          }).height(1200);
        
        $(window).trigger('resize.static-splash')
        
      teardown: ->
        require ['parabolasel'], (parabolasel) ->
          parabolasel.tearDown()
        $(window).unbind('resize.static-splash')
    contact: (data) ->
      return data
    resources: (data) ->
      return data
    jobs: ->
      return data
    
  unless singleton?
    console.log('initializing static_controller singleton')
    singleton = new StaticController()
  return singleton
