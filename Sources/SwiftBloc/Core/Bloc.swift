import Foundation
import Combine

/// A Bloc is a component which converts incoming events into outgoing states
/// Similar to Flutter's Bloc class
open class Bloc<Event: BlocEvent, State: BlocState>: Cubit<State> {
    
    /// Subject for handling incoming events
    private let eventSubject = PassthroughSubject<Event, Never>()
    
    /// Dictionary to store event handlers
    private var eventHandlers: [String: (Event) -> Void] = [:]
    
    /// Stream of all transitions
    private let transitionSubject = PassthroughSubject<Transition<Event, State>, Never>()
    public var transitionStream: AnyPublisher<Transition<Event, State>, Never> {
        return transitionSubject.eraseToAnyPublisher()
    }
    
    public override init(_ initialState: State) {
        super.init(initialState)
        
        // Set up event handling
        eventSubject
            .sink { [weak self] event in
                self?.handleEvent(event)
            }
            .store(in: &cancellables)
    }
    
    /// Adds an event to the bloc
    /// Similar to Flutter's add method
    public func add(_ event: Event) {
        guard !isClosed else {
            print("Warning: Cannot add event after bloc is closed")
            return
        }
        
        eventSubject.send(event)
    }
    
    /// Registers an event handler for a specific event type
    /// Similar to Flutter's on<Event> method
    public func on(_ eventType: Event.Type, handler: @escaping (Event) -> Void) {
        let key = String(describing: eventType)
        eventHandlers[key] = handler
    }
    
    /// Handles incoming events
    private func handleEvent(_ event: Event) {
        let eventTypeName = String(describing: type(of: event))
        
        if let handler = eventHandlers[eventTypeName] {
            let currentState = state
            handler(event)
            
            // If state changed, emit transition
            if state != currentState {
                let transition = Transition(currentState: currentState, event: event, nextState: state)
                onTransition(transition)
                transitionSubject.send(transition)
            }
        } else {
            print("Warning: No handler registered for event type \(eventTypeName)")
        }
    }
    
    /// Called whenever a transition occurs
    /// Override this method to add custom logging or side effects
    open func onTransition(_ transition: Transition<Event, State>) {
        // Override in subclass for custom behavior
    }
    
    /// Called whenever an event is added
    /// Override this method to add custom logging or side effects
    open func onEvent(_ event: Event) {
        // Override in subclass for custom behavior
    }
    
    /// Emits a new state and creates a transition if called within an event handler
    public override func emit(_ newState: State) {
        super.emit(newState)
    }
}
