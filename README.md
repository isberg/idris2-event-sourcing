# Idris2 Event Sourcing Library

This library provides a lightweight framework for building event-sourced systems in Idris2. Leveraging Idris2’s powerful type system and the Curry–Howard correspondence, the library allows you to model your domain using the Event Sourcing pattern, with a particular focus on the State Change Pattern (and later, the State View Pattern, Automation, and Translation patterns).

In an event-sourced system, every change to the application state is captured as an immutable event. Instead of storing just the current state, the entire history of events is stored. The state is then reconstituted (or "hydrated") by replaying these events. This approach makes your system auditable, testable, and robust against data corruption.

## Introduction

Event Sourcing is an architectural pattern where:
- **Every change** is recorded as an event.
- **State reconstruction** is achieved by folding over the event history.
- **Business logic** is encapsulated in a decider that translates operations into events.

The library defines a `Decider` interface that encapsulates the core of the State Change Pattern. This interface provides:
- A way to **decide** which events occur in response to an operation.
- A method to **evolve** the state by applying an event.
- A well-defined **initial state**.

## Example: A Positive-Only Counter

Below is a simple example demonstrating the State Change Pattern using a counter that can only be positive. The counter supports two operations: increment and decrement. When the counter is zero, the decrement operation produces no events, ensuring that the counter remains non-negative.

### Code Example

```idris2
module Domain.Counter

import EventSourcing.StateChangePattern

%default total

-- Define operations for the counter.
data Operation = Increment | Decrement

-- Define changes that occur in the counter.
data Change = Incremented | Decremented

-- The state of the counter is represented as a natural number.
State : Type
State = Nat

implementation Decider Operation Change State where
  -- The counter starts at zero.
  initialState = Z

  -- How the state evolves when a change occurs.
  evolve Incremented n = S n
  evolve Decremented Z = Z
  evolve Decremented (S n) = n

  -- How operations produce changes.
  decide Increment n = [Incremented]
  decide Decrement Z = []         -- Do nothing when at zero.
  decide Decrement (S n) = [Decremented]

-- Example usage:

-- Rehydrate the state from an event history.
exampleState : State
exampleState = hydrate [Incremented, Incremented, Decremented]  
-- Expected state: 1 (i.e., 0 + 1 + 1 - 1 = 1)
```

## Explanation

- **Decider Interface:**  
  The `Decider` interface defines:
  - **`decide`**: How an operation is translated into one or more changes.
  - **`evolve`**: How a single change updates the state.
  - **`initialState`**: The starting state for the system.

- **Helper Functions:**  
  - **`hydrate`**: Rebuilds the state by applying a list of changes starting from the initial state.
  - **`update`**: Combines decision-making and state evolution by applying an operation to the current state, yielding a new state and the corresponding changes.

- **Positive-Only Counter:**  
  In this example, the state is represented as a natural number (`Nat`). By defining `decide Decrement Z = []`, the implementation guarantees that the counter will not go below zero, ensuring that the counter remains positive-only.

## Getting Started

To integrate this library into your project:

1. **Add the Library:**  
   Add the event sourcing library to your Idris2 project.

2. **Import Modules:**  
   In your project files, import the necessary modules:
   - `EventSourcing.StateChangePattern`
   - Your domain-specific module (e.g., `Domain.Counter`).

3. **Define Your Domain:**  
   Create your domain’s operations, changes, and state. For example, define your operations as simple data types (e.g., `Increment`, `Decrement`) and your changes (e.g., `Incremented`, `Decremented`).

4. **Implement the Decider Interface:**  
   Implement the `Decider` interface for your domain by:
   - Providing the `initialState`.
   - Defining how each operation is turned into changes using `decide`.
   - Specifying how each change evolves the state using `evolve`.

5. **Utilize Helper Functions:**  
   Use the `hydrate` function to rebuild the current state from an event history, and the `update` function to apply new operations.

6. **Run and Test:**  
   Build your project and write tests or executable specifications to verify that your domain behaves as expected.

With these steps, you're ready to build robust, auditable, and testable event-sourced applications in Idris2!

