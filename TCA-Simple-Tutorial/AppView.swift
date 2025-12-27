//
//  AppView.swift
//  TCA-Simple-Tutorial
//
//  Created by OneTen on 12/27/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct AppFeature {
    @ObservableState
    struct State: Equatable {
        var tab1 = CounterFeature.State()
        var tab2 = ProfileFeature.State()
    }
    
    enum Action {
        case tab1(CounterFeature.Action)
        case tab2(ProfileFeature.Action)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.tab1, action: \.tab1) {
            CounterFeature()
        }
        
        Scope(state: \.tab2, action: \.tab2) {
            ProfileFeature()
        }
        
        // 자식들이 뭘 하든 부모가 감시하고 싶을 때 여기에 작성.
        Reduce { (state: inout State, action: Action) in
            switch action {
            // 자식(tab1)에게서 incrementButtonTapped 액션이 발생하면
            case .tab1(.incrementButtonTapped):
                // 부모가 개입해서 다른 자식(tab2)의 State를 수정
                if state.tab1.count >= 10 {
                    state.tab2.nickname = "숫자 세기 고수 🏅"
                } else {
                    state.tab2.nickname = "게스트"
                }
                return .none
                
            default:
                return .none
            }
        }
    }
}

struct AppView: View {
    let store: StoreOf<AppFeature>
    
    var body: some View {
        TabView {
            CounterView(store: store.scope(state: \.tab1, action: \.tab1))
                .tabItem {
                    Label("카운터", systemImage: "number.circle")
                }
            
            ProfileView(store: store.scope(state: \.tab2, action: \.tab2))
                .tabItem {
                    Label("프로필", systemImage: "person.circle")
                }
        }
    }
}
