//
//  NumberFactClient.swift
//  TCA-Simple-Tutorial
//
//  Created by OneTen on 12/26/25.
//

import Foundation

import ComposableArchitecture

// 1. API가 할 일을 정의 (Protocol 대신 struct + closure 패턴을 주로 사용)
struct NumberFactClient {
    var fetch: (Int) async throws -> String
}

// 2. 의존성 키(Key) 등록
extension DependencyValues {
    var numberFact: NumberFactClient {
        get { self[NumberFactClient.self] }
        set { self[NumberFactClient.self] = newValue }
    }
}

// 3. 실제 구현체와 가짜 구현체 등록
extension NumberFactClient: DependencyKey {
    // 실제 앱에서 쓸 'Live' 구현
    static let liveValue = Self(
        fetch: { number in
//            let urlString = "http://numbersapi.com/\(number)"
//            print("📡 [Network] 요청 시작: \(urlString)")
//            
//            do {
//                guard let url = URL(string: urlString) else {
//                    print("❌ [Network] URL 생성 실패: \(urlString)")
//                    throw URLError(.badURL)
//                }
//                
//                let (data, response) = try await URLSession.shared.data(from: url)
//                
//                if let httpResponse = response as? HTTPURLResponse {
//                    print("📡 [Network] 상태 코드: \(httpResponse.statusCode)")
//                }
//                
//                let resultString = String(decoding: data, as: UTF8.self)
//                print("✅ [Network] 데이터 수신 성공: \(resultString)")
//                
//                return resultString
//            } catch {
//                print("❌ [Network] 통신 에러 발생: \(error)")
//                throw error
//            }
            
            try await Task.sleep(nanoseconds: 1_000_000_000)
            
            // numbersapi 서버가 죽어있어서 테스트용으로 작성
            print("✅ [Mock] 가짜 데이터 리턴 성공")
            return "\(number) : 이 문구는 테스트용 네트워크 요청 리턴 값입니다! 🎉"
        }
    )
    
    // 프리뷰에서 쓸 가짜 데이터
    static let testValue = Self(
        fetch: { "\($0) is a good number." }
    )
}
