import SwiftUI
import Combine

/// A SwiftUI view that listens to BLoC state changes and executes side effects
/// Similar to Flutter's BlocListener
public struct BlocListener<B: Cubit<S>, S: BlocState, Content: View>: View {
    
    @StateObject private var bloc: B
    private let listener: (S) -> Void
    private let listenWhen: ((S, S) -> Bool)?
    private let content: Content
    
    @State private var previousState: S?
    
    /// Creates a BlocListener
    /// - Parameters:
    ///   - bloc: The bloc to listen to
    ///   - listenWhen: Optional condition to determine when to call listener
    ///   - listener: The callback to execute when state changes
    ///   - content: The child view content
    public init(
        bloc: B,
        listenWhen: ((S, S) -> Bool)? = nil,
        listener: @escaping (S) -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self._bloc = StateObject(wrappedValue: bloc)
        self.listenWhen = listenWhen
        self.listener = listener
        self.content = content()
    }
    
    public var body: some View {
        content
            .onReceive(bloc.stream) { newState in
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

/// A SwiftUI view that listens to BLoC state changes with access via environment
/// Similar to Flutter's BlocListener with context.read<Bloc>()
public struct BlocListenerWithContext<B: Cubit<S>, S: BlocState, Content: View>: View {
    
    @EnvironmentObject private var bloc: B
    private let listener: (S) -> Void
    private let listenWhen: ((S, S) -> Bool)?
    private let content: Content
    
    @State private var previousState: S?
    
    /// Creates a BlocListener that reads bloc from environment
    /// - Parameters:
    ///   - listenWhen: Optional condition to determine when to call listener
    ///   - listener: The callback to execute when state changes
    ///   - content: The child view content
    public init(
        listenWhen: ((S, S) -> Bool)? = nil,
        listener: @escaping (S) -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.listenWhen = listenWhen
        self.listener = listener
        self.content = content()
    }
    
    public var body: some View {
        content
            .onReceive(bloc.stream) { newState in
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
