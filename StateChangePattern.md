# The State Change Pattern

The **State Change Pattern** is at the heart of Event Modeling. It captures how the state of a system evolves over time in response to commands and events. In an event-sourced system, rather than storing the current state directly, every change is recorded as an immutable event. The current state is then *reconstructed* (or "rehydrated") by applying these events in sequence.

## How It Fits into Event Modeling

**Event Modeling** is a structured approach to designing systems that focuses on:
- **Event Storming:** Collaboratively exploring and mapping out a domain using domain events, commands, aggregates, and other elements.
- **Event Sourcing:** Persisting every change as an immutable event, which forms the source of truth for the system.
- **Executable Specifications:** Using scenarios (often in a Given/When/Then format) to define and test system behavior.

Within this context, the **State Change Pattern** addresses two primary questions:
1. **How do commands translate into domain events?**  
   A *decider* (or command handler) examines the current state and the incoming command, then decides which events should be recorded.
2. **How does the system evolve over time?**  
   Each event updates the system's state. By applying all events in sequence (often using a fold), you reconstruct the current state from the event history.

## Key Concepts in the State Change Pattern

- **Decider Interface:**  
  The decider defines two functions:
  - **`decide`:** Translates a command and current state into a list of events.
  - **`evolve`:** Applies a single event to update the state.
- **Initial State:**  
  A well-defined starting point for the system's state.
- **Hydration:**  
  The process of rebuilding the state from an event history, often implemented as a left fold (using a helper like `evolve'`).

## Example Code in Idris2

Below is an example of how you might define the State Change Pattern using Idris2. The following code shows the `Decider` interface along with its most important functions.

```idris2
module EventSourcing.StateChangePattern

%default total

-- The Decider interface defines how commands produce events and how events update the state.
public export
interface Decider command event state where
  -- Given a command and the current state, decide produces a list of events.
  decide : command -> state -> List event

  -- Given a single event and the current state, evolve updates the state.
  evolve : event -> state -> state

  -- The initial state of the system.
  initialState : state

-- evolve' recursively applies evolve over a list of events to reconstruct the state.
public export
evolve' : Decider command event state => state -> List event -> state
evolve' s [] = s
evolve' s (e :: es) = evolve' {command=command} (evolve {command=command} e s) es

-- hydrate rebuilds the state from an event history, starting at the initial state.
public export
hydrate : Decider command event state => List event -> state
hydrate = evolve' {command=command} $ initialState {command=command,event=event}

-- update applies a command to the current state, returning the new state along with generated events.
public export
update : Decider command event state => command -> state -> (state, List event)
update cmd currentState =
  let events = decide cmd currentState 
  in (evolve' {command=command} currentState events, events)

-- decide' is a helper that hydrates the state from an event history and then decides on events for a command.
public export
decide' : Decider command event state => command -> List event -> List event
decide' c es = decide c $ hydrate es {command=command,state=state}

-- update' is similar to update but works from an event history rather than an already hydrated state.
public export
update' : Decider command event state => command -> List event -> (state, List event)
update' c es = update c $ hydrate es {command=command}

```

## Explanation of the Code

- **Decider Interface:**  
  The `Decider` interface defines the three core functions:
  - `decide` translates a command and the current state into one or more events.
  - `evolve` specifies how a single event modifies the state.
  - `initialState` provides the starting point for the state.

- **Utility Functions:**  
  - `evolve'` uses recursion (or a left fold) to apply a list of events to a state, effectively reconstructing the state from an event history.
  - `hydrate` is a convenience function that starts the hydration process from the `initialState`.
  - `update` combines decision-making and state evolution by first calling `decide` and then applying `evolve'` to produce the new state along with the list of generated events.
  - `decide'` and `update'` are helper functions that work directly with an event history, making it easier to write executable specifications.

## Conclusion

The **State Change Pattern** is central to Event Modeling because it provides a clear, testable method for managing state changes in an event-sourced system. By separating the concerns of *decision-making* (via `decide`) and *state evolution* (via `evolve`), you ensure that business logic is both explicit and verifiable. The accompanying Idris2 code offers a concrete implementation of these concepts, allowing developers to build systems that are robust, auditable, and amenable to formal reasoning through the Curry–Howard correspondence.

