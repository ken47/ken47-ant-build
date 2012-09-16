define ['app/app_controller','app/app_config','app/layout_controller'], (AppController,AppConfig,LayoutController) ->
  class AppView
    constructor: ->

    custom_containers: {}
  
    custom_layouts: {
      static: {
        'splash': 'empty'
      }
    }
  
    default_container_selector: '#main'
    
    templates_loading: {}
  
    layouts_loading: {}

    current_layout: null
  
    handle404: (url) ->
      $(document).ready( ->
        $.jGrowl('The page "<em>' + url + '</em>" is not ready yet.', {
          theme: 'warning'
          animateOpen: {
            height: 'show'
          }
        })
      )
  
    setLayout: (req,layout_name,main_container_id) ->
      console.log 'calling setLayout'
      self = this
      layout_filename = "../templates/layouts/#{layout_name}.html"
      require ['text!'+layout_filename], (layout) ->
        LayoutController.teardown(self.current_layout)
        self.current_layout = layout_name
        $('body').html(layout).attr('id',layout_name)
        LayoutController.setup(layout_name)
        self.render(req)

    render: (req) ->
      self = this
      template_filename = "text!../templates/#{req.ctrl}/#{req.action}.html"
      ctrl_filename = "app/controllers/#{req.ctrl}_controller"
      
      require [template_filename,ctrl_filename], (template,Controller) ->
        layout_name = Controller[req.action].layout || Controller.default_layout || 'default'
        main_container_selector = Controller[req.action].main_container_selector || self.default_container_selector
  
        if layout_name isnt self.current_layout
          self.setLayout(req,layout_name,main_container_selector)
        else
          ko.cleanNode(main_container_selector)
          console.log main_container_selector
          console.log $(main_container_selector)
          $(main_container_selector).html(template)
          AppController.invoke(req)
          
  unless singleton?
    singleton = new AppView()

  return singleton
