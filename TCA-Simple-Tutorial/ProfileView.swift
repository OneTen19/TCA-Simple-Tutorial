//
//  ProfileView.swift
//  TCA-Simple-Tutorial
//
//  Created by OneTen on 12/27/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct ProfileFeature {
    @ObservableState
    struct State: Equatable {
        var nickname = "Guest"
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
    }
}

struct ProfileView: View {
    @Bindable var store: StoreOf<ProfileFeature>
    
    var body: some View {
        Form {
            Section {
                TextField("닉네임", text: $store.nickname)
                Text("반갑습니다, \(store.nickname)님! 👋")
            } header: {
                Text("내 정보")
            }
        }
    }
}
