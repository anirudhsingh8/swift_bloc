import Foundation

/// Base protocol for all states in the BLoC pattern
/// Similar to Flutter's BlocBase state
public protocol BlocState: Equatable {
    // States must be equatable for comparison
}

/// Base protocol for all events in the BLoC pattern
/// Similar to Flutter's BlocEvent
public protocol BlocEvent {
    // Events can be any type
}
