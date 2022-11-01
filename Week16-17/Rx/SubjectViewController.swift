//
//  SubjectViewController.swift
//  Week16-17
//
//  Created by SC on 2022/10/25.
//

import UIKit

import RxCocoa
import RxSwift


class SubjectViewController: UIViewController {
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var resetButton: UIBarButtonItem!
    @IBOutlet weak var newButton: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    let publish = PublishSubject<Int>()         // 초기값이 없는 빈 상태
    let behavior = BehaviorSubject(value: 100)  // 초기값 필수
    let replay = ReplaySubject<Int>.create(bufferSize: 3)  // bufferSize에 작성된 이벤트 갯수만큼 메모리에서 이벤트를 가지고 있다가, subscribe 직후 한 번에 이벤트를 전달
    let async = AsyncSubject<Int>()  // 거의 안 씀
    // Subject 종류 중에 Variable은 예전에 썼다가 이제는 안쓰는 것
    
    let disposeBag = DisposeBag()
    let viewModel = SubjectViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ContactCell")
        
        // Input & Output
        let input = SubjectViewModel.Input(addTap: addButton.rx.tap,
                                           resetTap: resetButton.rx.tap,
                                           newTap: newButton.rx.tap,
                                           searchText: searchBar.rx.text)
        
        let output = viewModel.transform(input: input)
        
        output.list
            .drive(tableView.rx.items(cellIdentifier: "ContactCell", cellType: UITableViewCell.self)) { (row, element, cell) in
                cell.textLabel?.text = "\(element.name): \(element.age)세, \(element.number)"
            }
            .disposed(by: disposeBag)

        output.addTap
            .withUnretained(self)
            .subscribe(onNext: { (vc, _) in
                vc.viewModel.fetchData()
            })
            .disposed(by: disposeBag)
        
        output.resetTap
            .withUnretained(self)
            .subscribe { (vc, _) in
                vc.viewModel.resetData()
            }
            .disposed(by: disposeBag)
        
        output.newTap
            .withUnretained(self)
            .subscribe { (vc, _) in
                vc.viewModel.newData()
            }
            .disposed(by: disposeBag)

        output.searchText
            .withUnretained(self)
            .subscribe { (vc, value) in
                print("====\(value)")
                vc.viewModel.filterData(query: value)
            }
            .disposed(by: disposeBag)
        
        
        
        
        viewModel.list  // VM -> VC (Output)
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(cellIdentifier: "ContactCell", cellType: UITableViewCell.self)) { (row, element, cell) in
                cell.textLabel?.text = "\(element.name): \(element.age)세, \(element.number)"
            }
//            .bind(to: tableView.rx.items(cellIdentifier: "ContactCell", cellType: UITableViewCell.self)) { (row, element, cell) in
//                cell.textLabel?.text = "\(element.name): \(element.age)세 (\(element.number))"
//            }
            .disposed(by: disposeBag)
        
        addButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { (vc, _) in
                vc.viewModel.fetchData()
            })
            .disposed(by: disposeBag)
        
        resetButton.rx.tap
            .withUnretained(self)
            .subscribe { (vc, _) in
                vc.viewModel.resetData()
            }
            .disposed(by: disposeBag)
        
        newButton.rx.tap
            .withUnretained(self)
            .subscribe { (vc, _) in
                vc.viewModel.newData()
            }
            .disposed(by: disposeBag)
        
        // VC -> VM (Input)
        searchBar.rx.text
            .orEmpty    // Transforms control property of type `String?` into control property of type `String`.
            .debounce(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)  // 기다리는 코드
            .distinctUntilChanged()  // 기존과 같은 값은 받지 않음 (orEmpty 바로 뒤에 작성 일단..)  // Observable<String>  // 여기까지 output.searchText로 바뀜
            .withUnretained(self)
            .subscribe { (vc, value) in
                print("====\(value)")
                vc.viewModel.filterData(query: value)
            }
            .disposed(by: disposeBag)


//        publishSubject()
//        behaviorSubject()
//        replaySubject()
//        asyncSubject()
    }
}

// Subject
extension SubjectViewController {
    func publishSubject() {
        // 초기값이 없는 빈 상태, subscribe 전 / error / comleted notification 이후에는 이벤트 무시
        // subscribe 후에 대한 이벤트는 다 처리
        // 구독 전이기 때문에 프린트되지 않음
        publish.onNext(1)
        publish.onNext(2)
        
        publish
            .subscribe { value in
                print("publish - \(value)")
            } onError: { error in
                print("publish - \(error)")
            } onCompleted: {
                print("publish - completed")
            } onDisposed: {
                print("publish - disposed")
            }
            .disposed(by: disposeBag)  // 리소스를 정리하는 객체를 subscribe 메서드에서 리턴해 주기 때문에 항상 아래쪽에서 dispose
        
        publish.onNext(3)     // next 이벤트만 보냈기 때문에 completed나 disposed 찍히지 않음
        publish.onNext(4)
        publish.on(.next(5))  // 상동
        
        publish.onCompleted()
        
        // 구독이 끝났기 때문에 프린트되지 않음
        publish.onNext(6)
        publish.onNext(7)
    }
    
    func behaviorSubject() {
        // 구독 전 가장 최근 값을 같이 emit
        behavior.onNext(1)
        behavior.onNext(200)  // 2부터 출력
        
        behavior
            .subscribe { value in
                print("behavior - \(value)")
            } onError: { error in
                print("behavior - \(error)")
            } onCompleted: {
                print("behavior - completed")
            } onDisposed: {
                print("behavior - disposed")
            }
            .disposed(by: disposeBag)
        
        behavior.onNext(3)     // next 이벤트만 보냈기 때문에 completed나 disposed 찍히지 않음
        behavior.onNext(4)
        behavior.on(.next(5))  // 상동
        
        behavior.onCompleted()
        
        // 구독이 끝났기 때문에 프린트되지 않음
        behavior.onNext(6)
        behavior.onNext(7)
    }
    
    func replaySubject() {
        // BufferSize - 메모리에 갖고 있게 된다
        // int 정도면 괜찮겠지만 array나 이미지 등의 경우 메모리에 많은 부하를 줄 수 있다는 점을 기억!
        // 초기값을 여러 개 가지고 있고 싶을 때 replaySubject를 써볼 수 있다
        replay.onNext(100)
        replay.onNext(200)
        replay.onNext(300)
        replay.onNext(400)
        replay.onNext(500)  // 300, 400, 500이 출력됨 (bufferSize가 3이기 때문)
        
        replay
            .subscribe { value in
                print("replay - \(value)")
            } onError: { error in
                print("replay - \(error)")
            } onCompleted: {
                print("replay - completed")
            } onDisposed: {
                print("replay - disposed")
            }
            .disposed(by: disposeBag)
        
        replay.onNext(3)     // next 이벤트만 보냈기 때문에 completed나 disposed 찍히지 않음
        replay.onNext(4)
        replay.on(.next(5))  // 상동
        
        replay.onCompleted()
        
        // 구독이 끝났기 때문에 프린트되지 않음
        replay.onNext(6)
        replay.onNext(7)
    }
    
    func asyncSubject() {
        async.onNext(100)
        async.onNext(200)
        async.onNext(300)
        async.onNext(400)
        async.onNext(500)  // 300, 400, 500이 출력됨 (bufferSize가 3이기 때문)

        async
            .subscribe { value in
                print("async - \(value)")
            } onError: { error in
                print("async - \(error)")
            } onCompleted: {
                print("async - completed")
            } onDisposed: {
                print("async - disposed")
            }
            .disposed(by: disposeBag)

        async.onNext(3)     // next 이벤트만 보냈기 때문에 completed나 disposed 찍히지 않음
        async.onNext(4)
        async.on(.next(5))  // 5만 프린트 됨!

        async.onCompleted()  // complete 이벤트를 만나야만 가장 최근 것 하나만 전달됨

        // 구독이 끝났기 때문에 프린트되지 않음
        async.onNext(6)
        async.onNext(7)
    }
}
