define ['app/app_view','app/app_services'], (AppView,AppServices) ->
  class AppController
    constructor: -> # may run into to memory issues if we store too much in memory
      # will deal w when time comes. probably need to implement garbage collection

    current_controller: null

    current_action: null

    # fill in with something useful later
    beforeInvoke: ->
      return true

    afterInvoke: ->
      return true

    invoke: (req) ->
      self = this
      this.beforeInvoke()
      ctrl_filename = "app/controllers/#{req.ctrl}_controller"
      
      require [ctrl_filename], (Controller) ->
        if self.current_controller? and self.current_action?
          previous_ctrl_filename = "app/controllers/#{self.current_controller}_controller"
          require [previous_ctrl_filename], (PreviousController) ->
            $('body').off(".#{self.current_controller}-#{self.current_action}")
            if PreviousController[self.current_action]['teardown']?
              PreviousController[self.current_action]['teardown']()
          , ->
            console.log "This should never happen."
  
        self.current_controller = req.ctrl
        self.current_action = req.action
  
        if Controller[req.action].title?
          document.title = Controller[req.action].title
  
        if Controller[req.action]['setup']?
          Controller[req.action]['setup']()
        
        if Controller[req.action]['view_models']?
          $.each(Controller[req.action]['view_models'], (container_id,params) ->
            AppServices.applyBindings(req,container_id,params)
          )

  unless singleton?
    singleton = new AppController()

  return singleton