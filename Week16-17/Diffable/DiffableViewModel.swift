//
//  DiffableViewModel.swift
//  Week16-17
//
//  Created by SC on 2022/10/20.
//

import Foundation
import RxSwift

enum SearchError: Error {
    case noPhoto
    case serverError
}

class DiffableViewModel {
//    var photoList: CObservable<SearchPhoto> = CObservable(SearchPhoto(total: 0, totalPages: 0, results: []))
    var photoList = PublishSubject<SearchPhoto>()  // 초기값 없이 검색했을 때 받는 구조이기 때문에 PublishSubject
    
    func requestSearchPhoto(query: String) {
        APIService.searchPhoto(query: query) { [weak self] photo, statusCode, error in
//            guard let statusCode = statusCode, statusCode == 500 else {
            guard let statusCode = statusCode else {
                self?.photoList.onError(SearchError.serverError)
                return
            }
            
            guard let photo = photo else {
                self?.photoList.onError(SearchError.noPhoto)
                return
            }
//            self.photoList.value = photo
            self?.photoList.onNext(photo)
        }
    }
}
