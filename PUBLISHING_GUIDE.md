# SwiftBloc Publishing and Usage Guide

## 📦 Publishing the Package

### 1. Prepare for Publishing

Before publishing your SwiftBloc package, ensure everything is ready:

```bash
# Navigate to your package directory
cd /Users/anirudhsingh/swift_bloc

# Verify package structure
swift package show-dependencies

# Run tests to ensure everything works
swift test

# Build the package
swift build
```

### 2. Initialize Git Repository

```bash
# Initialize git repository
git init

# Add all files
git add .

# Create initial commit
git commit -m "Initial commit: SwiftBloc v1.0.0 - Flutter BLoC pattern for Swift"

# Add your remote repository (replace with your GitHub repo)
git remote add origin https://github.com/yourusername/SwiftBloc.git

# Push to GitHub
git push -u origin main
```

### 3. Create GitHub Repository

1. Go to [GitHub.com](https://github.com)
2. Click "New Repository"
3. Name it `SwiftBloc`
4. Add description: "A Swift adaptation of the Flutter BLoC pattern for reactive state management"
5. Make it public
6. Don't initialize with README (we already have one)
7. Create repository

### 4. Tag a Release

```bash
# Create and push a tag for the first release
git tag v1.0.0
git push origin v1.0.0
```

### 5. Create GitHub Release

1. Go to your repository on GitHub
2. Click "Releases" → "Create a new release"
3. Choose tag `v1.0.0`
4. Title: "SwiftBloc v1.0.0"
5. Description:
```markdown
## SwiftBloc v1.0.0 🎉

First stable release of SwiftBloc - A Swift adaptation of the Flutter BLoC pattern!

### Features
- ✅ Exact Flutter BLoC API compatibility
- ✅ Type-safe state management with Cubit and Bloc
- ✅ SwiftUI integration with BlocBuilder, BlocListener, and BlocConsumer
- ✅ Dependency injection with BlocProvider
- ✅ Built on Combine framework
- ✅ Comprehensive test coverage
- ✅ Complete documentation and examples

### Supported Platforms
- iOS 14.0+
- macOS 11.0+
- tvOS 14.0+
- watchOS 7.0+

### Installation
Add to your project via Swift Package Manager:
\```
https://github.com/yourusername/SwiftBloc
\```
```

6. Publish release

## 🚀 Usage Instructions

### Quick Integration

#### 1. Add to Xcode Project

**Option A: Through Xcode**
1. File → Add Package Dependencies
2. Enter: `https://github.com/yourusername/SwiftBloc`
3. Choose "Up to Next Major Version" with 1.0.0
4. Add to your target

**Option B: Package.swift**
```swift
dependencies: [
    .package(url: "https://github.com/yourusername/SwiftBloc", from: "1.0.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: ["SwiftBloc"]
    )
]
```

#### 2. Import and Use

```swift
import SwiftBloc
import SwiftUI

// Your implementation here...
```

### Complete Usage Example

Here's a complete iOS app example using SwiftBloc:

#### 1. Create a new iOS project in Xcode

#### 2. Add SwiftBloc dependency

#### 3. Replace ContentView.swift:

```swift
import SwiftUI
import SwiftBloc

// MARK: - State & Events
extension Int: BlocState {}

enum CounterEvent: BlocEvent {
    case increment
    case decrement
    case reset
}

// MARK: - Business Logic
class CounterCubit: Cubit<Int> {
    init() {
        super.init(0)
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

class CounterBloc: Bloc<CounterEvent, Int> {
    override init() {
        super.init(0)
        
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
}

// MARK: - UI
struct ContentView: View {
    var body: some View {
        TabView {
            // Cubit Example
            CubitCounterView()
                .tabItem {
                    Label("Cubit", systemImage: "1.circle")
                }
            
            // Bloc Example
            BlocCounterView()
                .tabItem {
                    Label("Bloc", systemImage: "2.circle")
                }
            
            // Provider Example
            BlocProvider(create: { CounterCubit() }) {
                ProviderCounterView()
            }
            .tabItem {
                Label("Provider", systemImage: "3.circle")
            }
        }
    }
}

struct CubitCounterView: View {
    @StateObject private var cubit = CounterCubit()
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Cubit Counter")
                .font(.title)
            
            BlocBuilder(bloc: cubit) { state in
                Text("\\(state)")
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .foregroundColor(state > 0 ? .green : state < 0 ? .red : .blue)
            }
            
            HStack(spacing: 20) {
                Button("−") { cubit.decrement() }
                    .buttonStyle(.borderedProminent)
                    .font(.title)
                
                Button("Reset") { cubit.reset() }
                    .buttonStyle(.bordered)
                
                Button("+") { cubit.increment() }
                    .buttonStyle(.borderedProminent)
                    .font(.title)
            }
        }
        .padding()
    }
}

struct BlocCounterView: View {
    @StateObject private var bloc = CounterBloc()
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Bloc Counter")
                .font(.title)
            
            BlocConsumer(
                bloc: bloc,
                listener: { state in
                    if state == 10 {
                        // Show alert or haptic feedback
                        print("Reached 10! 🎉")
                    }
                },
                builder: { state in
                    Text("\\(state)")
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .foregroundColor(state > 0 ? .green : state < 0 ? .red : .blue)
                }
            )
            
            HStack(spacing: 20) {
                Button("−") { bloc.add(.decrement) }
                    .buttonStyle(.borderedProminent)
                    .font(.title)
                
                Button("Reset") { bloc.add(.reset) }
                    .buttonStyle(.bordered)
                
                Button("+") { bloc.add(.increment) }
                    .buttonStyle(.borderedProminent)
                    .font(.title)
            }
        }
        .padding()
    }
}

struct ProviderCounterView: View {
    var body: some View {
        VStack(spacing: 30) {
            Text("Provider Counter")
                .font(.title)
            
            BlocBuilderWithContext<CounterCubit, Int> { state in
                Text("\\(state)")
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .foregroundColor(state > 0 ? .green : state < 0 ? .red : .blue)
            }
            
            CounterButtons()
        }
        .padding()
    }
}

struct CounterButtons: View {
    @EnvironmentObject var cubit: CounterCubit
    
    var body: some View {
        HStack(spacing: 20) {
            Button("−") { cubit.decrement() }
                .buttonStyle(.borderedProminent)
                .font(.title)
            
            Button("Reset") { cubit.reset() }
                .buttonStyle(.bordered)
            
            Button("+") { cubit.increment() }
                .buttonStyle(.borderedProminent)
                .font(.title)
        }
    }
}

#Preview {
    ContentView()
}
```

#### 4. Run the app

Press Cmd+R to build and run your SwiftBloc-powered app!

## 📝 Best Practices

### 1. State Design
- Keep states immutable
- Use structs for complex states
- Implement proper Equatable conformance

### 2. Event Design
- Use descriptive event names
- Keep events simple and focused
- Group related events in enums

### 3. Business Logic
- Keep UI logic separate from business logic
- Use Cubit for simple state changes
- Use Bloc for complex event-driven logic
- Always handle async operations properly

### 4. Testing
- Test business logic separately from UI
- Use state streams for testing state changes
- Mock dependencies for isolated testing

### 5. Performance
- Use `buildWhen` and `listenWhen` for optimization
- Avoid unnecessary state emissions
- Keep state comparisons efficient

## 🔧 Advanced Configuration

### Custom Equality
```swift
struct UserState: BlocState {
    let users: [User]
    let selectedId: String?
    
    static func == (lhs: UserState, rhs: UserState) -> Bool {
        // Only compare IDs for performance
        return lhs.users.map(\.id) == rhs.users.map(\.id) &&
               lhs.selectedId == rhs.selectedId
    }
}
```

### Async Event Handling
```swift
class DataBloc: Bloc<DataEvent, DataState> {
    override init() {
        super.init(DataState.initial)
        
        on(DataEvent.self) { [weak self] event in
            Task {
                await self?.handleEvent(event)
            }
        }
    }
    
    private func handleEvent(_ event: DataEvent) async {
        // Handle async operations
    }
}
```

### Multiple Providers
```swift
MultiBlocProvider(
    providers: [
        AnyView(BlocProvider(create: { AuthBloc() }) { EmptyView() }),
        AnyView(BlocProvider(create: { UserBloc() }) { EmptyView() }),
        AnyView(BlocProvider(create: { SettingsBloc() }) { EmptyView() })
    ]
) {
    MainAppView()
}
```

## 🎉 Congratulations!

You've successfully created and can now publish SwiftBloc - a complete Flutter BLoC adaptation for Swift! The package provides:

- ✅ Complete feature parity with Flutter BLoC
- ✅ Native Swift and SwiftUI integration
- ✅ Type safety and performance
- ✅ Comprehensive documentation and examples
- ✅ Ready for production use

Share it with the Swift community and help bring predictable state management to iOS development! 🚀
