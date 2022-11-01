//
//  SubjectViewModel.swift
//  Week16-17
//
//  Created by SC on 2022/10/25.
//

import Foundation
import RxSwift
import RxCocoa

// associated type: Generic과 유사
// 뷰 모델들이 공통적으로 가지는 구조
protocol CommonViewModel {  // ViewModelType 이라고 만드는 예시들이 많다
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}

//class vm: CommonViewModel {
//    typealias Input = <#type#>
//
//    typealias Output = <#type#>
//
//
//}



struct Contact {
    var name: String
    var age: Int
    var number: String
}

class SubjectViewModel: CommonViewModel {
    var contactData = [
        Contact(name: "Jack", age: 23, number: "01012341234"),
        Contact(name: "Sani", age: 21, number: "01031231234"),
        Contact(name: "Doy", age: 21, number: "01031241234")
    ]
    
//    var list = PublishSubject<[Contact]>()
    var list = PublishRelay<[Contact]>()
    
    func fetchData() {
//        list.onNext(contactData)  // 등위연산자 대신 next 이벤트로 값을 넣어 준다
        list.accept(contactData)
    }
    
    func resetData() {
//        list.onNext([])
        list.accept([])
    }
    
    func newData() {
        let new = Contact(name: "고래밥", age: Int.random(in: 10...30), number: "")
//        list.onNext([new])  // 이렇게 하면 덮어씌워져 버린다
        
        // new를 추가하고 나서 list에 ContactData 넣기
        contactData.append(new)
//        list.onNext(contactData)
        list.accept(contactData)
    }
    
    func filterData(query: String) {
//        let filteredContacts = contactData.filter { $0.name.contains(query) }  // 내 코드
//        list.onNext(filteredContacts)
        
        let result = query != "" ? contactData.filter { $0.name.contains(query) } : contactData  // 수업 코드
//        list.onNext(result)
        list.accept(result)
    }
    
    
    
    // Input & Output
    struct Input {
        let addTap: ControlEvent<Void>  // ControlEvent<()>와 동일  // typealias Void = ()
        let resetTap: ControlEvent<Void>
        let newTap: ControlEvent<Void>
        let searchText: ControlProperty<String?>
    }
    
    struct Output {
        let addTap: ControlEvent<Void>
        let resetTap: ControlEvent<Void>
        let newTap: ControlEvent<Void>
        let list: Driver<[Contact]>
        let searchText: Observable<String>
    }
    
    func transform(input: Input) -> Output {
        let list = list.asDriver(onErrorJustReturn: [])
        
        let text = input.searchText
            .orEmpty
            .debounce(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)  // 기다리는 코드
            .distinctUntilChanged()  // 같은 값을 받지 않음
        
        return Output(addTap: input.addTap,
                      resetTap: input.resetTap,
                      newTap: input.newTap,
                      list: list,
                      searchText: text)
    }
}
