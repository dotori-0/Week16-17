//
//  SubjectViewModel.swift
//  Week16-17
//
//  Created by SC on 2022/10/25.
//

import Foundation
import RxSwift

struct Contact {
    var name: String
    var age: Int
    var number: String
}

class SubjectViewModel {
    var contactData = [
        Contact(name: "Jack", age: 23, number: "01012341234"),
        Contact(name: "Sani", age: 21, number: "01031231234"),
        Contact(name: "Doy", age: 21, number: "01031241234")
    ]
    
    var list = PublishSubject<[Contact]>()
    
    func fetchData() {
        list.onNext(contactData)  // 등위연산자 대신 next 이벤트로 값을 넣어 준다
    }
    
    func resetData() {
        list.onNext([])
    }
    
    func newData() {
        let new = Contact(name: "고래밥", age: Int.random(in: 10...30), number: "")
//        list.onNext([new])  // 이렇게 하면 덮어씌워져 버린다
        
        // new를 추가하고 나서 list에 ContactData 넣기
        contactData.append(new)
        list.onNext(contactData)
    }
    
    func filterData(query: String) {
//        let filteredContacts = contactData.filter { $0.name.contains(query) }  // 내 코드
//        list.onNext(filteredContacts)
        
        let result = query != "" ? contactData.filter { $0.name.contains(query) } : contactData  // 수업 코드
        list.onNext(result)
    }
}
