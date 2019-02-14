(exports ? this).SimpleEvent = class SimpleEvent
  __init: ->
    if !@_events
      @_events = {}
    if !@__events_asterisk
      @__events_asterisk = {}

  __bind_asterisk: (event, fct)->
    @__events_asterisk[event] = @__events_asterisk[event] or []
    @__events_asterisk[event].push fct
    @

  bind: (event, fct) ->
    @__init()
    if event.indexOf('*') >= 0
      return @__bind_asterisk event.split('*')[0], fct
    @_events[event] = @_events[event] or []
    @_events[event].push fct
    @

  __unbind_asterisk: (event, fct)->
    if not fct
      return delete @__events_asterisk[event]
    if not @__events_asterisk[event]
      return
    @__events_asterisk[event].splice @__events_asterisk[event].indexOf(fct), 1

  unbind: (event, fct) ->
    @__init()
    if event and event.indexOf('*') >= 0
      return @__unbind_asterisk event.split('*')[0], fct
    if not event
      @__events_asterisk = {}
      @_events = {}
      return
    if not fct
      return delete @_events[event]
    if not @_events[event]
      return
    @_events[event].splice @_events[event].indexOf(fct), 1
    @

  bind_to: (object, event, fn)->
    if !@__events_to
      @__events_to = []
    fn_c = => fn.apply(@, arguments)
    object[ if object.bind then 'bind' else 'on' ] event, fn_c
    @__events_to.push =>
      object[ if object.unbind then 'unbind' else 'off' ] event, fn_c
    @

  unbind_to: ->
    if @__events_to
      while fn = this.__events_to.shift()
        fn()
    @

  __trigger_asterisk: (event)->
    args = Array::slice.call(arguments, 1)
    Object.keys(@__events_asterisk).forEach (ev)=>
      if event.indexOf(ev) isnt 0
        return
      @__events_asterisk[ev].forEach (fn)=> fn.apply(@, [event.split(ev)[1]].concat(args))

  trigger: (event) ->
    @__init()
    @__trigger_asterisk.apply(@, Array::slice.call(arguments, 0))
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

SimpleEvent::on = SimpleEvent::bind
SimpleEvent::off = SimpleEvent::unbind
SimpleEvent::on_to = SimpleEvent::bind_to
SimpleEvent::off_to = SimpleEvent::unbind_to
SimpleEvent::emit = SimpleEvent::trigger
