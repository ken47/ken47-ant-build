define 'app_config', ->
  configuration: {}
  return {
    get: (key) ->
      return configuration[key]
    set: (key,value) ->
      configuration[key] = value
  }
