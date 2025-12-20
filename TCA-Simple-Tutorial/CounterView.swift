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
    }
    
    enum Action {
        case incrementButtonTapped  // 증가 버튼 클릭
        case decrementButtonTapped  // 감소 버튼 클릭
        case delayedIncrementButtonTapped // 지연 증가 버튼 클릭
        case incrementResponse // 1초가 지난 후 실제로 카운트를 올리라는 내부 액션
    }
    
    var body: some Reducer<State, Action> {
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
                
            }
        }
    }
}

struct CounterView: View {
    let store: StoreOf<CounterFeature>
    
    var body: some View {
        VStack {
            
            if store.isLoading {
                ProgressView()
                    .padding()
            } else {
                Text("\(store.count)")
                    .font(.largeTitle)
                    .padding()
            }
            
            HStack {
                Button("-") {
                    store.send(.decrementButtonTapped)
                }
                .font(.largeTitle)
                .padding()
                .background(Color.black.opacity(0.1))
                .cornerRadius(10)
                
                Button("+") {
                    store.send(.incrementButtonTapped)
                }
                .font(.largeTitle)
                .padding()
                .background(Color.black.opacity(0.1))
                .cornerRadius(10)
                
                Button("1초 뒤 증가") {
                    store.send(.delayedIncrementButtonTapped)
                }
                .font(.largeTitle)
                .padding()
                .background(Color.black.opacity(0.1))
                .cornerRadius(10)
            }
        }
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
