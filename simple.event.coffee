(exports ? this).SimpleEvent = class SimpleEvent

  bind: (event, fct) ->
    if !@_events
      @_events = {}
    @_events[event] = @_events[event] or []
    @_events[event].push fct
    @

  unbind: (event, fct) ->
    if !@_events
      return
    if not event
      return @_events = {}
    if not fct
      return delete @_events[event]
    if not @_events[event]
      return
    @_events[event].splice @_events[event].indexOf(fct), 1
    @

  bind_to: (object, event, fn)->
    if !@__events_to
      @__events_to = []
    fn_c = => fn.call(@, arguments)
    object.bind event, fn_c
    @__events_to.push => object.unbind event, fn_c

  unbind_to: ->
    if @__events_to
      while fn = this.__events_to.shift()
        fn()

  trigger: (event) ->
    if !@_events
      return
    args = Array::slice.call(arguments, 1)
    ['all', event].filter (ev)=> !!@_events[ev]
    .forEach (ev)=>
      @_events[ev].forEach (fn)=> fn.apply(@, if ev is 'all' then [event].concat(args) else args)
    @

  remove: ->
    @trigger 'remove'
    @unbind_to()
    @unbind()
    @
