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
}
