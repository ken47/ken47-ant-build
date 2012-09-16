define ->
  class AppServices
    view_models: {}
    timeouts: {}
    
    ###
    Ensures that the controller, action, and template files exist.
    ###
    validateRequest: (url,req) ->
      validated = false
      template_filename = "text!../templates/#{req.ctrl}/#{req.action}.html"
      ctrl_filename = "app/controllers/#{req.ctrl}_controller"
      console.log ctrl_filename
      
      require ['app/router'], (Router) ->
        require [template_filename], (template) ->
          require [ctrl_filename], (Controller) ->
            if Controller[req.action]?
              Router.handleValidRequest(url,req)
            else
              Router.handleInvalidRequest(url,req)
          , ->
              Router.handleInvalidRequest(url,req)
        , ->
          console.log 'template load failure...' + template_filename
          Router.handleInvalidRequest(url,req)
            
        
    getViewModelKey: (req) ->
      return req.ctrl + '-' + req.action
  
    applyBindings: (req,container_id,view_model) ->
      if view_model.poll? is on
        this.pollVmData(req,container_id,view_model)
      else
        this.getVmData(req,container_id,view_model)
        
    getVmData: (req,container_id,view_model) ->
      self = this
      
      if view_model.endpoint?
        endpoint = view_model.endpoint
      else
        endpoint = "#{req.ctrl}/#{req.action}"

      $.ajax({
        url: endpoint
        beforeSend: ->
        data: req.params
        processData: false
        success: (json) ->
          if not self.view_models[self.getViewModelKey(req)]?
            self.view_models[self.getViewModelKey(req)] = {}
          
          $.each(json, (prop,val) ->
            self.view_models[self.getViewModelKey(req)][prop] = val
          )
          ko.applyBindings(self.view_models[self.getViewModelKey(req)],document.getElementById(container_id))
        error: ->
          alert 'data retrieval failed. please try again.'
          require ['app/app_view'], (AppView) ->
            AppView.handle404()
      })
  
  unless singleton?
    singleton = new AppServices()

  return singleton
