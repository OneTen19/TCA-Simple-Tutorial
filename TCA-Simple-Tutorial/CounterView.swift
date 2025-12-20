//
//  ContentView.swift
//  TCA-Simple-Tutorial
//
//  Created by OneTen on 12/20/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct CounterFeature {
    @ObservableState
    struct State: Equatable {
        var count = 0
        var isLoading = false
        var isTimerEnabled = false
        var memo = ""
    }
    
    enum Action: BindableAction {
        case incrementButtonTapped
        case decrementButtonTapped
        case delayedIncrementButtonTapped
        case incrementResponse
        case binding(BindingAction<State>)
    }
    
    var body: some Reducer<State, Action> {
        
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .incrementButtonTapped:
                state.count += 1
                return .none
                
            case .decrementButtonTapped:
                state.count -= 1
                return .none
                
            case .delayedIncrementButtonTapped:
                state.isLoading = true  // 로딩 시작
                
                return .run { send in
                    // 복잡한 비동기 로직(API 호출, 타이머 등)을 수행.
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1초 대기
                    
                    // 작업이 끝나면 다시 Action을 날려서 State 변경.
                    await send(.incrementResponse)
                }
                
            case .incrementResponse:
                state.isLoading = false // 로딩 끝
                state.count += 1
                return .none
                
                
            // "들어온 binding 액션이 정확히 'isTimerEnabled' 변수를 건드린 경우라면 이쪽으로 와라"
            case .binding(\.isTimerEnabled):
                print("타이머 스위치가 변경되었습니다: \(state.isTimerEnabled)")
                return .none
                
            // "위에서 걸러지지 않은 나머지 모든 binding 액션은 여기서 처리해라"
            case .binding:
                return .none
            }
        }
    }
    
}

struct CounterView: View {
    @Bindable var store: StoreOf<CounterFeature>
    
    var body: some View {
        VStack {
            if store.isLoading {
                ProgressView().padding()
            } else {
                Text("\(store.count)")
                    .font(.largeTitle)
                    .padding()
            }
            
            HStack {
                Button("-") { store.send(.decrementButtonTapped) }
                    .font(.largeTitle)
                    .padding()
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(10)
                
                Button("+") { store.send(.incrementButtonTapped) }
                    .font(.largeTitle)
                    .padding()
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(10)
                
                Button("1초 뒤") { store.send(.delayedIncrementButtonTapped) }
                    .font(.headline)
                    .padding()
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(10)
            }
            .padding()
            
            Divider().padding()
            
            Toggle("타이머 활성화", isOn: $store.isTimerEnabled)
                .padding()
                .background(store.isTimerEnabled ? Color.green.opacity(0.2) : Color.gray.opacity(0.1))
                .cornerRadius(8)
            
            TextField("메모를 입력하세요", text: $store.memo)
                .textFieldStyle(.roundedBorder)
                .padding(.top)
            
            Text("입력 중: \(store.memo)")
                .font(.caption)
                .foregroundStyle(.gray)
        }
        .padding()
    }
}

#Preview {
    CounterView(
        store: Store(initialState: CounterFeature.State()) {
            CounterFeature()
                ._printChanges()
        }
    )
}
