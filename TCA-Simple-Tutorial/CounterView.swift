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
        var fact: String?
    }
    
    enum Action: BindableAction {
        case incrementButtonTapped
        case decrementButtonTapped
        case delayedIncrementButtonTapped
        case incrementResponse
        case binding(BindingAction<State>)
        case factButtonTapped
        case factResponse(String)
    }
    
    
    // \.continuousClock은 TCA가 기본으로 제공하는 시간 관련 도구
    @Dependency(\.continuousClock) var clock
    
    // 방금 만든 API Client 주입
    @Dependency(\.numberFact) var numberFact
    
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
                state.isLoading = true
                
                // Task.sleep 대신 clock.sleep을 사용
                return .run { send in
                    // try await Task.sleep(nanoseconds: 1_000_000_000) // ❌ 이제 이거 안 씀
                    try await clock.sleep(for: .seconds(1))             // ✅ TCA continuousClock 사용
                    
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
                
                // 사실 가져오기 버튼 클릭
            case .factButtonTapped:
                print("🟢 [Reducer] 버튼 클릭됨. 통신 시도.")
                state.fact = nil
                state.isLoading = true
                
                return .run { [count = state.count] send in
                    print("🏃 [Reducer] .run 블록 진입")
                    do {
                        let fact = try await numberFact.fetch(count)
                        print("📩 [Reducer] 결과 받음, Action 발송: \(fact)")
                        await send(.factResponse(fact))
                    } catch {
                        print("🔥 [Reducer] 에러 발생 (catch): \(error)")
                        await send(.factResponse("에러: \(error.localizedDescription)"))
                    }
                }
                
                // 결과 받아서 화면에 표시
            case .factResponse(let fact):
                print("🏁 [Reducer] .factResponse 도착: \(fact)")
                state.isLoading = false
                state.fact = fact
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
            
            Button("이 숫자의 비밀은? 🕵️‍♀️") {
                store.send(.factButtonTapped)
            }
            .padding()
            .background(Color.orange)
            .foregroundColor(.white)
            .cornerRadius(8)
            
            if let fact = store.fact {
                Text(fact)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.yellow.opacity(0.2))
                    .cornerRadius(8)
            }
            
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
