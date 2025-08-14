# SwiftBloc

[![Swift](https://img.shields.io/badge/Swift-5.7+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS-lightgrey.svg)](https://developer.apple.com/swift/)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-Compatible-green.svg)](https://developer.apple.com/xcode/swiftui/)

**SwiftBloc** is a Swift adaptation of the Flutter BLoC (Business Logic Component) pattern, providing predictable state management for Swift and SwiftUI applications.

## 🎯 Features

- ✅ **Exact Flutter BLoC API**: Same syntax and writing style as Flutter BLoC
- ✅ **Type-Safe**: Leverages Swift's type system for compile-time safety
- ✅ **SwiftUI Integration**: Purpose-built widgets for seamless SwiftUI integration
- ✅ **Reactive**: Built on Combine framework for reactive programming
- ✅ **Testable**: Easy to test business logic with built-in testing utilities
- ✅ **Cubit & Bloc**: Support for both simple Cubit and event-driven Bloc patterns
- ✅ **Dependency Injection**: BlocProvider for clean dependency management

## 📦 Installation

### Swift Package Manager

Add SwiftBloc to your project using Xcode:

1. File → Add Package Dependencies
2. Enter package URL: `https://github.com/anirudhsingh8/swift_bloc`
3. Select version and add to target

Or add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/anirudhsingh8/swift_bloc", from: "1.0.0")
]
```

## 🚀 Quick Start

### 1. Define State and Events

```swift
import SwiftBloc

// State must conform to BlocState (which requires Equatable)
extension Int: BlocState {}

// Events must conform to BlocEvent
enum CounterEvent: BlocEvent {
    case increment
    case decrement
    case reset
}
```

### 2. Create a Cubit (Simple State Management)

```swift
class CounterCubit: Cubit<Int> {
    init() {
        super.init(0) // Initial state
    }
    
    func increment() {
        emit(state + 1)
    }
    
    func decrement() {
        emit(state - 1)
    }
    
    func reset() {
        emit(0)
    }
}
```

### 3. Create a Bloc (Event-Driven State Management)

```swift
class CounterBloc: Bloc<CounterEvent, Int> {
    override init() {
        super.init(0) // Initial state
        
        // Register event handlers
        on(CounterEvent.self) { [weak self] event in
            guard let self = self else { return }
            
            switch event {
            case .increment:
                self.emit(self.state + 1)
            case .decrement:
                self.emit(self.state - 1)
            case .reset:
                self.emit(0)
            }
        }
    }
    
    // Optional: Override for logging/debugging
    override func onTransition(_ transition: Transition<CounterEvent, Int>) {
        print("Transition: \(transition)")
    }
}
```

### 4. Use in SwiftUI

#### With BlocBuilder

```swift
struct CounterView: View {
    @StateObject private var cubit = CounterCubit()
    
    var body: some View {
        VStack {
            // Rebuilds when state changes
            BlocBuilder(bloc: cubit) { state in
                Text("Count: \\(state)")
                    .font(.largeTitle)
            }
            
            HStack {
                Button("−") { cubit.decrement() }
                Button("Reset") { cubit.reset() }
                Button("+") { cubit.increment() }
            }
        }
    }
}
```

#### With BlocConsumer (Builder + Listener)

```swift
struct CounterView: View {
    @StateObject private var bloc = CounterBloc()
    
    var body: some View {
        BlocConsumer(
            bloc: bloc,
            listener: { state in
                // Side effects
                if state == 10 {
                    print("You reached 10!")
                }
            },
            builder: { state in
                VStack {
                    Text("Count: \\(state)")
                    
                    HStack {
                        Button("−") { bloc.add(.decrement) }
                        Button("Reset") { bloc.add(.reset) }
                        Button("+") { bloc.add(.increment) }
                    }
                }
            }
        )
    }
}
```

#### With BlocProvider (Dependency Injection)

```swift
struct App: View {
    var body: some View {
        BlocProvider(create: { CounterCubit() }) {
            CounterScreen()
        }
    }
}

struct CounterScreen: View {
    var body: some View {
        VStack {
            // Reads cubit from environment
            BlocBuilderWithContext<CounterCubit, Int> { state in
                Text("Count: \\(state)")
            }
            
            CounterButtons()
        }
    }
}

struct CounterButtons: View {
    @EnvironmentObject var cubit: CounterCubit
    
    var body: some View {
        HStack {
            Button("−") { cubit.decrement() }
            Button("Reset") { cubit.reset() }
            Button("+") { cubit.increment() }
        }
    }
}
```

## 📚 Core Concepts

### Cubit vs Bloc

| Cubit | Bloc |
|-------|------|
| Simple methods to emit states | Event-driven architecture |
| `cubit.increment()` | `bloc.add(.increment)` |
| Good for simple state management | Good for complex business logic |
| No events, just method calls | Explicit events for all state changes |

### Widgets

| Widget | Purpose |
|--------|---------|
| `BlocBuilder` | Rebuilds UI when state changes |
| `BlocListener` | Executes side effects on state changes |
| `BlocConsumer` | Combines BlocBuilder + BlocListener |
| `BlocProvider` | Provides bloc to widget tree |

### State Requirements

States must conform to `BlocState` (which requires `Equatable`):

```swift
struct LoadingState: BlocState {
    let isLoading: Bool
    let data: [String]
    let error: String?
    
    // Equatable conformance
    static func == (lhs: LoadingState, rhs: LoadingState) -> Bool {
        return lhs.isLoading == rhs.isLoading &&
               lhs.data == rhs.data &&
               lhs.error == rhs.error
    }
}
```

## 🧪 Testing

SwiftBloc is designed to be easily testable:

```swift
import XCTest
@testable import YourApp

class CounterCubitTests: XCTestCase {
    var cubit: CounterCubit!
    
    override func setUp() {
        cubit = CounterCubit()
    }
    
    func testInitialState() {
        XCTAssertEqual(cubit.state, 0)
    }
    
    func testIncrement() {
        cubit.increment()
        XCTAssertEqual(cubit.state, 1)
    }
    
    func testStateStream() {
        let expectation = XCTestExpectation(description: "State change")
        
        cubit.stream
            .dropFirst() // Skip initial state
            .sink { state in
                XCTAssertEqual(state, 1)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        cubit.increment()
        wait(for: [expectation], timeout: 1.0)
    }
}
```

## 🔄 Migration from Flutter BLoC

SwiftBloc provides exact API compatibility with Flutter BLoC:

| Flutter BLoC | SwiftBloc |
|--------------|-----------|
| `Cubit<State>` | `Cubit<State>` |
| `Bloc<Event, State>` | `Bloc<Event, State>` |
| `cubit.emit(state)` | `cubit.emit(state)` |
| `bloc.add(event)` | `bloc.add(event)` |
| `BlocBuilder` | `BlocBuilder` |
| `BlocListener` | `BlocListener` |
| `BlocConsumer` | `BlocConsumer` |
| `BlocProvider` | `BlocProvider` |
| `context.read<Bloc>()` | `@EnvironmentObject` |

## 🎨 Advanced Usage

### Custom State Types

```swift
struct UserState: BlocState {
    let user: User?
    let isLoading: Bool
    let error: Error?
    
    static func == (lhs: UserState, rhs: UserState) -> Bool {
        // Custom equality implementation
        return lhs.user?.id == rhs.user?.id &&
               lhs.isLoading == rhs.isLoading &&
               lhs.error?.localizedDescription == rhs.error?.localizedDescription
    }
}

enum UserEvent: BlocEvent {
    case loadUser(id: String)
    case userLoaded(User)
    case userError(Error)
}
```

### Async Operations

```swift
class UserBloc: Bloc<UserEvent, UserState> {
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
        super.init(UserState())
        
        on(UserEvent.self) { [weak self] event in
            await self?.handleEvent(event)
        }
    }
    
    private func handleEvent(_ event: UserEvent) async {
        switch event {
        case .loadUser(let id):
            emit(UserState(isLoading: true))
            
            do {
                let user = try await userRepository.getUser(id: id)
                add(.userLoaded(user))
            } catch {
                add(.userError(error))
            }
            
        case .userLoaded(let user):
            emit(UserState(user: user))
            
        case .userError(let error):
            emit(UserState(error: error))
        }
    }
}
```

### Conditional Rebuilding

```swift
BlocBuilder(
    bloc: counterCubit,
    buildWhen: { previous, current in
        // Only rebuild when count is even
        return current % 2 == 0
    }
) { state in
    Text("Even count: \\(state)")
}
```

## 📖 Examples

Check out the `Examples/` directory for comprehensive examples including:

- **Basic Counter**: Simple increment/decrement with Cubit and Bloc
- **Data Loading**: Async operations with loading states
- **Complex State**: Custom state types with multiple properties
- **Provider Pattern**: Dependency injection with BlocProvider

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

SwiftBloc is available under the MIT license. See the LICENSE file for more info.

## 🙏 Acknowledgments

- Inspired by the [Flutter BLoC library](https://bloclibrary.dev)
- Built with love for the Swift community

---

**Happy coding with SwiftBloc! 🚀**
