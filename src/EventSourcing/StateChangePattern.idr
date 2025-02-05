module EventSourcing.StateChangePattern

%default total

public export
interface Decider command event state where
  decide : command -> state -> List event
  evolve : event -> state -> state
  initialState : state

public export
evolve' : Decider command event state => state -> List event -> state
evolve' s [] = s
evolve' s (e :: es) = evolve' {command=command} (evolve {command=command} e s) es

public export
hydrate : Decider command event state => List event -> state
hydrate = evolve' {command=command} $ initialState {command=command,event=event}

public export
update : Decider command event state => command -> state -> (state, List event)
update cmd currentState =
  let events = decide cmd currentState 
  in (evolve' {command=command} currentState events, events)

public export
decide' : Decider command event state => command -> List event -> List event
decide' c es = decide c $ hydrate es {command=command,state=state}

public export
update' : Decider command event state => command -> List event -> (state, List event)
update' c es = update c $ hydrate es {command=command}
