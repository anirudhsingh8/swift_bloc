import XCTest
import Combine
@testable import SwiftBloc

// Make Int conform to BlocState for testing
extension Int: BlocState {}

final class SwiftBlocTests: XCTestCase {
    
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }
    
    // MARK: - Cubit Tests
    
    func testCubitInitialState() {
        let cubit = CounterCubit()
        XCTAssertEqual(cubit.state, 0)
        XCTAssertFalse(cubit.isClosed)
    }
    
    func testCubitEmit() {
        let cubit = CounterCubit()
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
    
    func testCubitClose() {
        let cubit = CounterCubit()
        cubit.close()
        
        XCTAssertTrue(cubit.isClosed)
        
        // Should not emit after closing
        cubit.emit(5)
        XCTAssertEqual(cubit.state, 0) // Should still be initial state
    }
    
    // MARK: - Bloc Tests
    
    func testBlocInitialState() {
        let bloc = CounterBloc()
        XCTAssertEqual(bloc.state, 0)
        XCTAssertFalse(bloc.isClosed)
    }
    
    func testBlocEventHandling() {
        let bloc = CounterBloc()
        let expectation = XCTestExpectation(description: "State change from event")
        
        bloc.stream
            .dropFirst() // Skip initial state
            .sink { state in
                XCTAssertEqual(state, 1)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        bloc.add(.increment)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testBlocTransitions() {
        let bloc = CounterBloc()
        let expectation = XCTestExpectation(description: "Transition")
        
        bloc.transitionStream
            .sink { transition in
                XCTAssertEqual(transition.currentState, 0)
                XCTAssertEqual(transition.nextState, 1)
                if case .increment = transition.event {
                    expectation.fulfill()
                } else {
                    XCTFail("Wrong event type")
                }
            }
            .store(in: &cancellables)
        
        bloc.add(.increment)
        
        wait(for: [expectation], timeout: 1.0)
    }
}

// MARK: - Test Implementations

// Test Cubit
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
}

// Test Event
enum CounterEvent: BlocEvent {
    case increment
    case decrement
}

// Test Bloc
class CounterBloc: Bloc<CounterEvent, Int> {
    init() {
        super.init(0)
        
        on(CounterEvent.self) { [weak self] event in
            switch event {
            case .increment:
                self?.emit((self?.state ?? 0) + 1)
            case .decrement:
                self?.emit((self?.state ?? 0) - 1)
            }
        }
    }
}
