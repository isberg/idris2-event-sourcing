module EventSourcing.StateViewPattern

%default total

public export
interface ReadModel event state where
  evolve : event -> state -> state
  initialState : state

public export
evolve' : ReadModel event state => state -> List event -> state
evolve' s [] = s
evolve' s (e :: es) = evolve' (evolve e s) es

public export
hydrate : ReadModel event state => List event -> state
hydrate = evolve' $ initialState {event=event}


