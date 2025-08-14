import SwiftUI

/// A SwiftUI view that provides a bloc to its descendants
/// Similar to Flutter's BlocProvider
public struct BlocProvider<B: Cubit<S>, S: BlocState, Content: View>: View {
    
    private let bloc: B
    private let content: Content
    
    /// Creates a BlocProvider
    /// - Parameters:
    ///   - create: A closure that creates the bloc instance
    ///   - content: The child view content
    public init(
        create: () -> B,
        @ViewBuilder content: () -> Content
    ) {
        self.bloc = create()
        self.content = content()
    }
    
    /// Creates a BlocProvider with an existing bloc
    /// - Parameters:
    ///   - value: The bloc instance to provide
    ///   - content: The child view content
    public init(
        value: B,
        @ViewBuilder content: () -> Content
    ) {
        self.bloc = value
        self.content = content()
    }
    
    public var body: some View {
        content
            .environmentObject(bloc)
    }
}

/// A SwiftUI view that provides multiple blocs to its descendants
/// Similar to Flutter's MultiBlocProvider
public struct MultiBlocProvider<Content: View>: View {
    
    private let providers: [AnyView]
    private let content: Content
    
    /// Creates a MultiBlocProvider
    /// - Parameters:
    ///   - providers: Array of BlocProvider views
    ///   - content: The child view content
    public init(
        providers: [AnyView],
        @ViewBuilder content: () -> Content
    ) {
        self.providers = providers
        self.content = content()
    }
    
    public var body: some View {
        providers.reversed().reduce(AnyView(content)) { result, provider in
            AnyView(provider)
        }
    }
}

/// Extension to help with MultiBlocProvider creation
public extension Array where Element == AnyView {
    static func blocProviders<B1: Cubit<S1>, S1: BlocState>(
        _ bloc1: B1
    ) -> [AnyView] {
        return [
            AnyView(BlocProvider(value: bloc1) { EmptyView() })
        ]
    }
    
    static func blocProviders<B1: Cubit<S1>, S1: BlocState, B2: Cubit<S2>, S2: BlocState>(
        _ bloc1: B1,
        _ bloc2: B2
    ) -> [AnyView] {
        return [
            AnyView(BlocProvider(value: bloc1) { EmptyView() }),
            AnyView(BlocProvider(value: bloc2) { EmptyView() })
        ]
    }
}

/// A property wrapper that provides easy access to blocs from the environment
/// Similar to Flutter's context.read<Bloc>()
@propertyWrapper
public struct BlocContext<B: ObservableObject> {
    @EnvironmentObject private var bloc: B
    
    public var wrappedValue: B {
        return bloc
    }
    
    public init() {}
}
