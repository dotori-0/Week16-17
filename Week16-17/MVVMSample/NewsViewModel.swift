//
//  NewsViewModel.swift
//  Week16-17
//
//  Created by SC on 2022/10/20.
//

import Foundation

class NewsViewModel {
    var pageNumber: CObservable<String> = CObservable("3000")
    
    var dummyNews: CObservable<[News.NewsItem]> = CObservable(News.items)

    func changePageNumberFormat(text: String) {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        // 333,333 일단 쉼표가 한 번 찍히고 나면 Int로 바뀌지 않아서 listener 실행 X -> 쉼표 없애기
        let text = text.replacingOccurrences(of: ",", with: "")
        
        guard let number = Int(text) else { return }
        let result = numberFormatter.string(for: number)!
        pageNumber.value = result
    }
    
    func resetSample() {
        dummyNews.value = []
    }
    
    func loadSample() {
        dummyNews.value = News.items
    }
}
