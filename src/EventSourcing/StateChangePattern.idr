module EventSourcing.StateChangePattern

import EventSourcing.StateViewPattern

%default total

public export
interface ReadModel event state => Decider command event state where
  decide : command -> state -> List event

public export
update : Decider command event state => command -> state -> (state, List event)
update cmd currentState =
  let events = decide cmd currentState 
  in (evolve' currentState events, events)

public export
decide' : Decider command event state => command -> List event -> List event
decide' c es = decide c $ hydrate es {state=state}

public export
update' : Decider command event state => command -> List event -> (state, List event)
update' c es = update c $ hydrate es 
