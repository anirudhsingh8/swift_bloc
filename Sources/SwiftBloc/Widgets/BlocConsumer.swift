import SwiftUI
import Combine

/// A SwiftUI view that combines BlocBuilder and BlocListener
/// Similar to Flutter's BlocConsumer
public struct BlocConsumer<B: Cubit<S>, S: BlocState, Content: View>: View {
    
    @StateObject private var bloc: B
    private let builder: (S) -> Content
    private let listener: (S) -> Void
    private let buildWhen: ((S, S) -> Bool)?
    private let listenWhen: ((S, S) -> Bool)?
    
    @State private var previousState: S?
    
    /// Creates a BlocConsumer
    /// - Parameters:
    ///   - bloc: The bloc to listen to
    ///   - buildWhen: Optional condition to determine when to rebuild
    ///   - listenWhen: Optional condition to determine when to call listener
    ///   - listener: The callback to execute when state changes
    ///   - builder: The view builder that creates content based on state
    public init(
        bloc: B,
        buildWhen: ((S, S) -> Bool)? = nil,
        listenWhen: ((S, S) -> Bool)? = nil,
        listener: @escaping (S) -> Void,
        @ViewBuilder builder: @escaping (S) -> Content
    ) {
        self._bloc = StateObject(wrappedValue: bloc)
        self.buildWhen = buildWhen
        self.listenWhen = listenWhen
        self.listener = listener
        self.builder = builder
    }
    
    public var body: some View {
        builder(bloc.state)
            .onReceive(bloc.stream) { newState in
                // Handle listener
                if let previous = previousState {
                    let shouldListen = listenWhen?(previous, newState) ?? true
                    if shouldListen {
                        listener(newState)
                    }
                }
                previousState = newState
            }
            .onAppear {
                previousState = bloc.state
            }
    }
}

/// A SwiftUI view that combines BlocBuilder and BlocListener with access via environment
/// Similar to Flutter's BlocConsumer with context.read<Bloc>()
public struct BlocConsumerWithContext<B: Cubit<S>, S: BlocState, Content: View>: View {
    
    @EnvironmentObject private var bloc: B
    private let builder: (S) -> Content
    private let listener: (S) -> Void
    private let buildWhen: ((S, S) -> Bool)?
    private let listenWhen: ((S, S) -> Bool)?
    
    @State private var previousState: S?
    
    /// Creates a BlocConsumer that reads bloc from environment
    /// - Parameters:
    ///   - buildWhen: Optional condition to determine when to rebuild
    ///   - listenWhen: Optional condition to determine when to call listener
    ///   - listener: The callback to execute when state changes
    ///   - builder: The view builder that creates content based on state
    public init(
        buildWhen: ((S, S) -> Bool)? = nil,
        listenWhen: ((S, S) -> Bool)? = nil,
        listener: @escaping (S) -> Void,
        @ViewBuilder builder: @escaping (S) -> Content
    ) {
        self.buildWhen = buildWhen
        self.listenWhen = listenWhen
        self.listener = listener
        self.builder = builder
    }
    
    public var body: some View {
        builder(bloc.state)
            .onReceive(bloc.stream) { newState in
                // Handle listener
                if let previous = previousState {
                    let shouldListen = listenWhen?(previous, newState) ?? true
                    if shouldListen {
                        listener(newState)
                    }
                }
                previousState = newState
            }
            .onAppear {
                previousState = bloc.state
            }
    }
}
