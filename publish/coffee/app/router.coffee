# TODO ensure that empty hash routes to default route
# Router assumes that user isn't trying to break routing system
# by inputting more than one slash in an unexpected location
# or using more than 1 '#' character
define ['app/app_view','app/app_services'], (AppView,AppServices) ->
  class Router
    default_route: 'static/splash'
  
    default_url: ''
  
    current_url: null
  
    homepage: 'splash'

    webroot: null

    invalid_request: null

    constructor: ->
      self = this
      
      console.log 'initializing router'

      this.setWebroot()
    
      # if user uses a non-ajax url such as
      # www.lyfe.is/users/view/5
      # we want to transform that to
      # www.lyfe.is/!#/users/view/5
#      if window.location.hash.length is 0
#        self.setHash(window.location.href)

    listen: ->
      self = this
      $(document).ready ->
        # links will point to static url's
        # so this intercepts any attempts to visit a link
        # and transforms the static url into ajax
        $('body').on('click','a:not(.not-route)', (e) ->
          e.preventDefault();
          window.scrollTo(0,0)
          self.route($(this).attr('href'))
          # self.setHash($(this).attr('href'))
          return false
        )

      window.onhashchange = ->
        self.route()
        
      this.route()
    
    # tested on ie7
    setWebroot: ->
      this.webroot = window.location.href.split('//').pop()

    extractHash: ->
      console.log window.location.href
      if window.location.href.search('#') < 0
        return ''
      else
        return window.location.hash.split('#/').pop()

    # this needs to handle hashes which are manually inputted
    # as well as anchor tags
    route: (url = null) ->
      url = this.getRelativeUrl(url)
      
      if this.current_url is url
        return true
      
      request = this.parseRequest(url)
      
      if !request
        return AppView.handle404(url)

      AppServices.validateRequest(url,request)

    getRelativeUrl: (url) ->
      if not url?
        console.log url
        url = this.extractHash()
      else
        console.log 'url'
        url = this.extractRelativeUrl(url)

    getCurrentRequest: (url = null) ->
      url = this.getRelativeUrl()
      return this.parseRequest(url)

    handleValidRequest: (url,req) ->
      console.log 'handleValidRequest'
      this.current_url = url
      this.setHash(url)
      $('body').trigger('new-route', req)
      AppView.render(req)
      
    handleInvalidRequest: (url,req) ->
      # requireJs is doing something odd. when a file does not exist,
      # it sometimes calls the errback twice, thus generating two notices when visiting an invalid url
      if this.invalid_request isnt url
        this.invalid_request = url
        if this.current_url?
          this.setHash(this.current_url)
        else
          this.setHash(this.default_url)
        
        AppView.handle404(url)

    extractRelativeUrl: (url) ->
      # default page
      if url.search('#') > -1
        return AppServices.handle404()
      
      if url.search(this.webroot)
        url = url.split(this.webroot).pop()

      # check for leading slash and remove if there is one    
      # unless the url is only a forward slash, which is the homepage
      if url.search('/') is 0 and url.length > 1 
        url = url.substring(1)
        
      return url
          
    parseRequest: (url = null) ->
      params = null
      invalid_url = false
  
      # hash can either by completely empty, or only a forward slash, both of which should
      # point to the default route
      
      if url is '' or url is '/'
        url = this.default_route
        
      url_components = url.split("/")
      
      if url_components.length is 1
        controller = 'static'
        action = url_components[0]
      else
        controller = url_components[0]
        action = url_components[1]
      
      # any hash components beyond the first two will be treated as GET params 
      if url_components.length > 2
        raw_params = []
        params = {}
        raw_params.push(arg) for arg, i in url_components when i > 2 
        
        for raw_param in raw_params
          result = raw_param.split(':')
          if ( result.length != 2 )
            invalid_url = true
            break
          params[result[0]] = result[1]
  
      if invalid_url
        AppView.handle404()
        return false
          
      return {
        ctrl: controller
        action: action
        params: params
      }
          
    setHash: (url) ->
      window.location.hash = '/' + url

  unless singleton?
    singleton = new Router()

  return singleton