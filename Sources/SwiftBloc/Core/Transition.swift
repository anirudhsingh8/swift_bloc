import Foundation

/// Represents a change from one state to another
/// Similar to Flutter's Transition class
public struct Transition<Event: BlocEvent, State: BlocState> {
    /// The current state before the transition
    public let currentState: State
    
    /// The event that triggered this transition
    public let event: Event
    
    /// The next state after the transition
    public let nextState: State
    
    public init(currentState: State, event: Event, nextState: State) {
        self.currentState = currentState
        self.event = event
        self.nextState = nextState
    }
}

extension Transition: CustomStringConvertible {
    public var description: String {
        return "Transition { currentState: \(currentState), event: \(event), nextState: \(nextState) }"
    }
}
