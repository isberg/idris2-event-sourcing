module EventSourcing.StateChangePattern

%default total

public export
interface Decider command event state where
  decide : command -> state -> List event
  evolve : event -> state -> state
  initialState : state

{- Passing of implicit parameters in generic code
   The utility functions below are written to work with all implementations
   of the Decider interface. In order to not confuse the compiler, sometimes
   an implicit (type) parameter is needed to be passed explicitly, so that
   the correct interface implementation can be choosen and the right functions.

   Passing implicit parameters are done like `f {param=value}`. When having 
   multiple function applications in the same expression, paranteses can be needed
   to pair the parameter with the right function call.
-}

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
