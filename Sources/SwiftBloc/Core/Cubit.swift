import Foundation
import Combine

/// A Cubit is a subset of Bloc which has no events and relies on methods to emit new states
/// Similar to Flutter's Cubit class
open class Cubit<State: BlocState>: ObservableObject {
    
    /// The current state of the cubit
    @Published public private(set) var state: State
    
    /// Stream of all state changes
    public var stream: Published<State>.Publisher {
        return $state
    }
    
    /// Whether the cubit is closed
    private var _isClosed = false
    public var isClosed: Bool { _isClosed }
    
    /// Set to store cancellables
    internal var cancellables = Set<AnyCancellable>()
    
    /// Initializes the cubit with an initial state
    public init(_ initialState: State) {
        self.state = initialState
        
        // Set up state change observation for debugging
        stream
            .sink { [weak self] newState in
                self?.onChange(Change(currentState: self?.state ?? initialState, nextState: newState))
            }
            .store(in: &cancellables)
    }
    
    /// Emits a new state
    /// Similar to Flutter's emit method
    public func emit(_ newState: State) {
        guard !isClosed else {
            print("Warning: Cannot emit state after cubit is closed")
            return
        }
        
        if state != newState {
            state = newState
        }
    }
    
    /// Called whenever a state change occurs
    /// Override this method to add custom logging or side effects
    open func onChange(_ change: Change<State>) {
        // Override in subclass for custom behavior
    }
    
    /// Called when an error occurs
    /// Override this method to handle errors
    open func onError(_ error: Error) {
        print("Cubit Error: \(error)")
    }
    
    /// Closes the cubit and cancels all subscriptions
    public func close() {
        _isClosed = true
        cancellables.removeAll()
    }
    
    deinit {
        close()
    }
}

/// Represents a change from one state to another in a Cubit
public struct Change<State: BlocState> {
    /// The current state before the change
    public let currentState: State
    
    /// The next state after the change
    public let nextState: State
    
    public init(currentState: State, nextState: State) {
        self.currentState = currentState
        self.nextState = nextState
    }
}

extension Change: CustomStringConvertible {
    public var description: String {
        return "Change { currentState: \(currentState), nextState: \(nextState) }"
    }
}
