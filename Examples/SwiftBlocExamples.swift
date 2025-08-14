import SwiftUI
import SwiftBloc

// MARK: - Counter Example

// 1. Define the state (must conform to BlocState)
extension Int: BlocState {}

// 2. Define events (must conform to BlocEvent)
enum CounterEvent: BlocEvent {
    case increment
    case decrement
    case reset
}

// 3. Create a Cubit (simpler, no events)
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

// 4. Create a Bloc (event-driven)
class CounterBloc: Bloc<CounterEvent, Int> {
    init() {
        super.init(0)
        
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
    
    // Override to add logging
    override func onTransition(_ transition: Transition<CounterEvent, Int>) {
        print("Transition: \(transition)")
    }
}

// 5. SwiftUI Views using Cubit

struct CounterCubitView: View {
    @StateObject private var cubit = CounterCubit()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Counter Cubit Example")
                .font(.title)
            
            // Using BlocBuilder
            BlocBuilder(bloc: cubit) { state in
                Text("Count: \(state)")
                    .font(.largeTitle)
                    .foregroundColor(state > 0 ? .green : state < 0 ? .red : .blue)
            }
            
            HStack(spacing: 20) {
                Button("Decrement") {
                    cubit.decrement()
                }
                .buttonStyle(.bordered)
                
                Button("Reset") {
                    cubit.reset()
                }
                .buttonStyle(.bordered)
                
                Button("Increment") {
                    cubit.increment()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
    }
}

// 6. SwiftUI Views using Bloc

struct CounterBlocView: View {
    @StateObject private var bloc = CounterBloc()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Counter Bloc Example")
                .font(.title)
            
            // Using BlocConsumer (combines BlocBuilder + BlocListener)
            BlocConsumer(
                bloc: bloc,
                listener: { state in
                    // Side effects
                    if state == 10 {
                        print("Congratulations! You reached 10!")
                    }
                },
                builder: { state in
                    Text("Count: \(state)")
                        .font(.largeTitle)
                        .foregroundColor(state > 0 ? .green : state < 0 ? .red : .blue)
                }
            )
            
            HStack(spacing: 20) {
                Button("Decrement") {
                    bloc.add(.decrement)
                }
                .buttonStyle(.bordered)
                
                Button("Reset") {
                    bloc.add(.reset)
                }
                .buttonStyle(.bordered)
                
                Button("Increment") {
                    bloc.add(.increment)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
    }
}

// 7. Using BlocProvider for dependency injection

struct CounterApp: View {
    var body: some View {
        TabView {
            // Cubit Example
            CounterCubitView()
                .tabItem {
                    Label("Cubit", systemImage: "1.circle")
                }
            
            // Bloc Example
            CounterBlocView()
                .tabItem {
                    Label("Bloc", systemImage: "2.circle")
                }
            
            // Provider Example
            BlocProvider(create: { CounterCubit() }) {
                CounterProviderView()
            }
            .tabItem {
                Label("Provider", systemImage: "3.circle")
            }
        }
    }
}

// 8. Using BlocProvider and environment

struct CounterProviderView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Counter Provider Example")
                .font(.title)
            
            // Using BlocBuilderWithContext (reads from environment)
            BlocBuilderWithContext<CounterCubit, Int> { state in
                Text("Count: \(state)")
                    .font(.largeTitle)
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
            Button("Decrement") {
                cubit.decrement()
            }
            .buttonStyle(.bordered)
            
            Button("Reset") {
                cubit.reset()
            }
            .buttonStyle(.bordered)
            
            Button("Increment") {
                cubit.increment()
            }
            .buttonStyle(.bordered)
        }
    }
}

// MARK: - Advanced Example with Custom State

// Complex state example
struct LoadingState: BlocState {
    let isLoading: Bool
    let data: [String]
    let error: String?
    
    init(isLoading: Bool = false, data: [String] = [], error: String? = nil) {
        self.isLoading = isLoading
        self.data = data
        self.error = error
    }
    
    static func == (lhs: LoadingState, rhs: LoadingState) -> Bool {
        return lhs.isLoading == rhs.isLoading &&
               lhs.data == rhs.data &&
               lhs.error == rhs.error
    }
}

enum DataEvent: BlocEvent {
    case loadData
    case dataLoaded([String])
    case dataError(String)
}

class DataBloc: Bloc<DataEvent, LoadingState> {
    init() {
        super.init(LoadingState())
        
        on(DataEvent.self) { [weak self] event in
            guard let self = self else { return }
            
            switch event {
            case .loadData:
                self.emit(LoadingState(isLoading: true))
                self.loadDataAsync()
                
            case .dataLoaded(let data):
                self.emit(LoadingState(data: data))
                
            case .dataError(let error):
                self.emit(LoadingState(error: error))
            }
        }
    }
    
    private func loadDataAsync() {
        // Simulate async operation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if Bool.random() {
                self.add(.dataLoaded(["Item 1", "Item 2", "Item 3"]))
            } else {
                self.add(.dataError("Failed to load data"))
            }
        }
    }
}

struct DataView: View {
    @StateObject private var bloc = DataBloc()
    
    var body: some View {
        VStack {
            Text("Advanced Data Loading Example")
                .font(.title)
            
            BlocBuilder(bloc: bloc) { state in
                if state.isLoading {
                    ProgressView("Loading...")
                } else if let error = state.error {
                    VStack {
                        Text("Error: \(error)")
                            .foregroundColor(.red)
                        Button("Retry") {
                            bloc.add(.loadData)
                        }
                        .buttonStyle(.bordered)
                    }
                } else {
                    List(state.data, id: \.self) { item in
                        Text(item)
                    }
                }
            }
            
            Button("Load Data") {
                bloc.add(.loadData)
            }
            .buttonStyle(.borderedProminent)
            .disabled(bloc.state.isLoading)
        }
        .padding()
    }
}

#Preview {
    CounterApp()
}
