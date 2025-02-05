# Event Modeling in Context

**Event Modeling** is an approach that builds upon the insights gathered during an **Event Storming** session and provides a structured way to describe how a system behaves over time. It captures not only what happens in a system (the events) but also how those events transform state, trigger further actions, and how they can be observed or integrated with external systems.

**Event Storming** is an exploratory, collaborative workshop method used to map out a complex business domain. During these sessions, participants use colored sticky notes (or similar visual aids) to identify and classify key elements:
- **Domain Events:** What happened in the system.
- **Commands:** Intentions to perform an action.
- **Aggregates:** Clusters of domain logic that enforce consistency.
- **Read Models:** Projections that provide a user-friendly or automated view of the system's state.
- **Actors, Policies, External Systems, and Bounded Contexts:** Other elements that provide context or trigger domain behavior.

Once a domain has been explored using Event Storming, **Event Modeling** takes the next step by formalizing expectations using a Given/When/Then format (similar to Behavior-Driven Development). This results in executable specifications that map out the exact flow of events when commands are issued, making the design both clear and testable.

**Event Sourcing** is the underlying architectural principle where every change to the application state is stored as a sequence of immutable events. The event log is the source of truth:
- **State Reconstruction:** The current state is “hydrated” by folding over the event log.
- **Auditability and Replayability:** Since all events are stored, you can always reconstruct past states or re-run events if needed.

---

## The Four Key Patterns in Event Modeling

Event Modeling is built around four core patterns, each addressing a different aspect of the system's behavior:

1. **State Change Pattern**
2. **State View Pattern**
3. **Automation Pattern**
4. **Translation Pattern**

### 1. State Change Pattern

**Purpose:**  
This pattern captures the core business logic by describing how the state of the system evolves in response to commands and events. It is implemented using a *decider* that:
- **Receives Commands:** Represents a user or system’s intent.
- **Produces Domain Events:** Reflects what actually happens in the system.
- **Rebuilds State:** By applying events over time.

**Key Concepts:**
- **`initialState`:** Defines the starting state of the domain.
- **`decide`:** A function that, given a command and the current state, produces a list of events (or no events if the command is invalid).
- **`evolve`:** A function that describes how a single event updates the current state.
- **`evolve'`:** A utility (often implemented as a left fold) that applies `evolve` to a sequence of events, reconstructing the current state.
- **`update` and `update'`:** Functions that combine decision-making and state evolution, allowing commands to be applied to a hydrated state.

**Why It’s Important:**  
By separating the “intent” (command) from “what happened” (event), and then explicitly defining how events change the state, the State Change Pattern ensures that the business rules are both clear and verifiable. In systems built with Event Sourcing, this pattern is essential because it lets you rehydrate the state from the event log, ensuring that every decision is auditable.

---

### 2. State View Pattern

**Purpose:**  
This pattern addresses the need to present a projection or read model of the current state. While the State Change Pattern is about *what happened* and *how the state changes*, the State View Pattern is about *how that state is presented* for users or automated processes.

**Key Concepts:**
- **`initialView`:** The starting projection of the system, often similar to `initialState` but tailored for display or reporting.
- **`project`:** A function that takes the current view and an event, producing an updated view.
- **`project'`:** A utility function (again, typically implemented as a fold) that applies `project` across a sequence of events.
- **`readHydrate`:** A convenience function that “hydrates” the read model from an event history by starting with `initialView` and applying `project'`.

**Why It’s Important:**  
The State View Pattern is crucial for systems that need to provide real-time insights or a user-friendly interface. By maintaining a read model that is a projection of the event history, you can offer up-to-date information without recalculating the entire state on the fly. This separation of concerns also allows you to optimize and scale the read side independently of the write side.

---

### 3. Automation Pattern

**Purpose:**  
This pattern is about triggering further actions automatically when certain events occur. For instance, an automation might be set up to notify an external system or update a related read model.

**Key Concepts:**
- It listens for specific events in the event log or read model changes.
- When the event matches a certain condition, it issues a command to perform an action.

**Relationship to Other Patterns:**  
The Automation Pattern typically integrates with the State View Pattern. Since read models are designed for easy consumption, they can serve as triggers for automations without the need to inspect the entire event history manually.

---

### 4. Translation Pattern

**Purpose:**  
The Translation Pattern deals with the interface between the internal event model and external systems. It converts external events (or commands) into internal representations and vice versa.

**Key Concepts:**
- **Incoming Translation:** Converts external inputs into domain events that your system can process.
- **Outgoing Translation:** Prepares internal events for consumption by external systems, ensuring they meet the required formats or protocols.

**Why It’s Important:**  
By isolating translation logic, you keep the core domain logic clean and focused on business rules. Changes in external systems or protocols can be managed in the translation layer without affecting the internal workings of your event-sourced system.

---

## Conclusion

**Event Modeling** integrates with **Event Storming** and **Event Sourcing** to provide a complete picture of your system's behavior:

- **Event Storming** gives you the initial, collaborative mapping of the domain.
- **Event Modeling** refines this into executable scenarios using the Given/When/Then format.
- **Event Sourcing** then ensures that every change is captured as an immutable event log, from which the system's state can be reconstructed.

Among the four patterns, the **State Change Pattern** and **State View Pattern** are central:
- The **State Change Pattern** defines *how commands result in events and state changes*.
- The **State View Pattern** focuses on *projecting the event history into a view* that is easily consumed by users or automation processes.

Together, these patterns provide a powerful and testable framework for building event-driven systems that are both robust and transparent, while also facilitating automated proofs and verifications in languages that support the Curry–Howard correspondence (like Idris2).

