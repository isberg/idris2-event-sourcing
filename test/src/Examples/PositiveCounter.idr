module Examples.PositiveCounter

import EventSourcing.StateChangePattern
import Data.Nat

data Command = Increment | Decrement | Clear

data Event = Incremented | Decremented | Cleared

Decider Command Event Nat where
  initialState = Z
  evolve Incremented state = S state
  evolve Decremented state = pred state
  evolve Cleared state = Z
  decide Increment state = [Incremented]
  decide Decrement 0 = []
  decide Decrement (S k) = [Decremented]
  decide Clear state = [Cleared]

-- Utility function helpful for testing and to write cleaner tests
verify : Command -> List Event -> List Event
verify = decide' {state=Nat} -- {state=Nat} is needed to exactly specify all parameters to Decider so the right decide' and decide are used

verify_Increment: (es : List Event) -> verify Increment es = [Incremented]
verify_Increment [] = Refl
verify_Increment (x :: xs) = verify_Increment xs

verify_DecrementNil : verify Decrement [] = []
verify_DecrementNil = Refl

lemma_evolve'Incremented : (state : Nat) -> (es : List Event) 
  -> evolve' {command=Command,state=Nat} state (es ++ [Incremented]) = evolve' {command=Command} (evolve' {command=Command} state es) [Incremented]
lemma_evolve'Incremented 0 [] = Refl
lemma_evolve'Incremented 0 (x :: xs) = lemma_evolve'Incremented (evolve {command=Command} x 0) xs
lemma_evolve'Incremented (S k) [] = Refl
lemma_evolve'Incremented (S k) (x :: xs) = lemma_evolve'Incremented (evolve {command=Command} x (S k)) xs

verify_DecrementIncremented : (es : List Event) -> verify Decrement (es ++ [Incremented]) = [Decremented]
verify_DecrementIncremented es = 
  rewrite (lemma_evolve'Incremented 0 es) in 
  Refl

