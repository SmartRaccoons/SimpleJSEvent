class SimpleEvent
  constructor: ->
    @_events = {}

  bind: (event, fct) ->
    @_events[event] = @_events[event] or []
    @_events[event].push fct

  unbind: (event, fct) ->
    if not event
      return @_events = {}
    if not fct
      return delete @_events[event]
    if not @_events[event]
      return
    @_events[event].splice @_events[event].indexOf(fct), 1

  trigger: (event) ->
    args = Array::slice.call(arguments, 1)
    ['all', event].filter (ev)=> !!@_events[ev]
    .forEach (ev)=>
      @_events[ev].forEach (fn)=> fn.apply(@, if ev is 'all' then [event].concat(args) else args)

  remove: ->
    @trigger 'remove'
    @unbind()


if typeof module isnt "undefined" and 'exports' of module
  module.exports = SimpleEvent
else
  window.SimpleEvent = SimpleEvent
