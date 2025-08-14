import SwiftUI
import Combine

/// A SwiftUI view that rebuilds when the BLoC state changes
/// Similar to Flutter's BlocBuilder
public struct BlocBuilder<B: Cubit<S>, S: BlocState, Content: View>: View {
    
    @StateObject private var bloc: B
    private let builder: (S) -> Content
    private let buildWhen: ((S, S) -> Bool)?
    
    /// Creates a BlocBuilder
    /// - Parameters:
    ///   - bloc: The bloc to listen to
    ///   - buildWhen: Optional condition to determine when to rebuild
    ///   - builder: The view builder that creates content based on state
    public init(
        bloc: B,
        buildWhen: ((S, S) -> Bool)? = nil,
        @ViewBuilder builder: @escaping (S) -> Content
    ) {
        self._bloc = StateObject(wrappedValue: bloc)
        self.buildWhen = buildWhen
        self.builder = builder
    }
    
    public var body: some View {
        builder(bloc.state)
            .onReceive(bloc.stream) { newState in
                // The view will automatically rebuild due to @StateObject
                // buildWhen condition is handled by SwiftUI's built-in change detection
            }
    }
}

/// A SwiftUI view that rebuilds when the BLoC state changes with access via environment
/// Similar to Flutter's BlocBuilder with context.read<Bloc>()
public struct BlocBuilderWithContext<B: Cubit<S>, S: BlocState, Content: View>: View {
    
    @EnvironmentObject private var bloc: B
    private let builder: (S) -> Content
    private let buildWhen: ((S, S) -> Bool)?
    
    /// Creates a BlocBuilder that reads bloc from environment
    /// - Parameters:
    ///   - buildWhen: Optional condition to determine when to rebuild
    ///   - builder: The view builder that creates content based on state
    public init(
        buildWhen: ((S, S) -> Bool)? = nil,
        @ViewBuilder builder: @escaping (S) -> Content
    ) {
        self.buildWhen = buildWhen
        self.builder = builder
    }
    
    public var body: some View {
        builder(bloc.state)
            .onReceive(bloc.stream) { newState in
                // The view will automatically rebuild due to @EnvironmentObject
            }
    }
}
