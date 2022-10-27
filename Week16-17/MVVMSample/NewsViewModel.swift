//
//  NewsViewModel.swift
//  Week16-17
//
//  Created by SC on 2022/10/20.
//

import Foundation

import RxSwift
import RxCocoa

class NewsViewModel {
//    var pageNumber: CObservable<String> = CObservable("3000")
//    var pageNumber = BehaviorSubject(value: 3000)  // 타입은 추론 가능한 경우에는 생략해도 됨
    var pageNumber = BehaviorSubject<String>(value: "3,000")  // RxSwift  // RxCocoa로 바꿔 보기
    
//    var dummyNews: CObservable<[News.NewsItem]> = CObservable(News.items)
//    var dummyNews = BehaviorSubject(value: News.items)
    var dummyNews = BehaviorRelay(value: News.items)  // RxCocoa // error와 complete 이벤트를 없는 상황으로 만들어 버린다

    func changePageNumberFormat(text: String) {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        // 333,333 일단 쉼표가 한 번 찍히고 나면 Int로 바뀌지 않아서 listener 실행 X -> 쉼표 없애기
        let text = text.replacingOccurrences(of: ",", with: "")
        
        guard let number = Int(text) else { return }
        let result = numberFormatter.string(for: number)!
//        pageNumber.value = result
        pageNumber.onNext(result)  // RxSwift
    }
    
    func resetSample() {
//        dummyNews.value = []
//        dummyNews.onNext([])  // RxSwift
        dummyNews.accept([])  // RxCocoa
    }
    
    func loadSample() {
//        dummyNews.value = News.items
//        dummyNews.onNext(News.items)  // RxSwift
        dummyNews.accept(News.items)  // RxCocoa
    }
}
