import gleam/erlang/process.{type Subject}

/// Represents a bond between an actor subject and its parent subject
pub type ActorParentBond(m) = #(Subject(m), Subject(Subject(m)))
