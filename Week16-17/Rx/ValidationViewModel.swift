//
//  ValidationViewModel.swift
//  Week16-17
//
//  Created by SC on 2022/10/27.
//

import Foundation
import RxSwift
import RxCocoa

class ValidationViewModel {
    let validText = BehaviorRelay(value: "닉네임은 최소 8자 이상 필요해요")  // 절대 변경이 되지 않을 객체라면 Rx 객체로 선언할 필요 X
    
    struct Input {
        let text: ControlProperty<String?>  // nameTextfield.rx.text
        let tap: ControlEvent<Void>         // stepButton.rx.tap
    }
    
    struct Output {
        let validation: Observable<Bool>
        let tap: ControlEvent<Void>
        let text: Driver<String>
    }
    
    func transform(input: Input) -> Output {  // VC에서 할 수 있는 것을 한 번 더 데이터 영역으로 분리
        let valid = input.text  // valid: Observable<Bool>
            .orEmpty
            .map { $0.count >= 8 }
            .share()
        
        let text = validText.asDriver()
        
        // input.tap: 별도의 연산이 없다면 그대로 반환하는 것도 가능
        return Output(validation: valid, tap: input.tap, text: text)
    }
}
