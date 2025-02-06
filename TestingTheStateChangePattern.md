# Testing the State Change Pattern with Proofs

One of the major benefits of using a dependently typed language like Idris2 is the ability to encode and verify properties of your program as types. This is an example of the Curry–Howard correspondence, where propositions are represented as types and proofs as programs. In our event sourcing library, we can use this feature to verify that our domain logic behaves as expected.

Below is an example that tests the State Change Pattern using our Counter domain. In this example, we provide proofs (using `Refl`) that demonstrate the correctness of our implementation. The Idris2 compiler checks these proofs at compile time.

## Example: Testing the Counter Domain

Consider our positive-only counter. The counter supports two operations: increment and decrement. When the counter is zero, attempting to decrement produces no changes.

Here’s how you might write tests for this behavior:

```idris2
module Domain.CounterTest

import Domain.Counter         -- Imports our Counter domain definitions and the Decider instance.
import EventSourcing.StateChangePattern

%default total

%inline
decide'_ : Operation -> List Change -> List Change 
decide'_ = decide' {state=State}

{-| 
Test: Increment Operation

Given an empty event history (counter starts at zero) and the Increment operation,
the expected generated change is [Incremented].
-}
incrementTest : decide'_ Increment [] = [Incremented]
incrementTest = Refl

{-| 
Test: Decrement Operation at Zero

Given an empty event history (counter is zero) and the Decrement operation,
no changes should be produced because the counter cannot go below zero.
-}
decrementAtZeroTest : decide'_ Decrement [] = []
decrementAtZeroTest = Refl

{-| 
Test: Decrement Operation on a Positive Counter

Given an event history that increments the counter twice (resulting in a state of 2),
when the Decrement operation is applied, the expected generated change is [Decremented].
-}
decrementTest : decide'_ Decrement [Incremented, Incremented] = [Decremented]
decrementTest = Refl

```

## How It Works

The library simplifies testing by providing a helper function that fixes the implicit state parameter. This helper, `decide'_`, allows you to supply an operation and an event history and directly obtain the corresponding changes. Internally, it hydrates the current state from the event history and applies the `decide` function from the Decider interface, abstracting away the need to manually pass state parameters.

Leveraging Idris2’s support for the Curry–Howard correspondence, the library encodes properties of the domain as types. In this setting, types represent propositions about how operations should behave, and proofs (such as those using `Refl`) serve as evidence that these propositions hold. The compiler then verifies these proofs at compile time, ensuring that the domain logic meets its specifications.

## Summary

The helper function `decide'_` streamlines testing by allowing you to focus solely on the relationship between operations and their resulting changes, without dealing with implicit parameters. By taking advantage of Idris2’s Curry–Howard correspondence, the library lets you encode and verify important properties of your event-sourced system as types and proofs. This approach provides robust compile-time guarantees, catching errors early and making your system more reliable and maintainable.

