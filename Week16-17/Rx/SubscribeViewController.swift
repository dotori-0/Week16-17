//
//  SubscribeViewController.swift
//  Week16-17
//
//  Created by SC on 2022/10/26.
//

import UIKit

import RxAlamofire
import RxCocoa
import RxDataSources
import RxSwift

class SubscribeViewController: UIViewController {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let disposeBag = DisposeBag()
    
    // 필요한 시점에 초기화가 될 수 있도록 lazy var
    lazy var dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Int>>(configureCell: { dataSource, tableView, indexPath, item in
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        cell.textLabel?.text = "\(item)"
        return cell
    })
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        testRxAlamofire()
        testRxDataSource()
        
//        Observable.of(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
//            .skip(3)                 // 4, 5, 6, 7, 8, 9, 10  // 3 개의 이벤트는 무시하고 4부터 전달하는 오퍼레이터
////            .debug()
//            .filter { $0 % 2 == 0 }  // 4, 6, 8, 10
//            .debug()
//            .map { $0 * 2 }          // 8, 12, 16, 20
////            .debug()
//            .subscribe { value in
//                print("===\(value)")
//            }
//            .disposed(by: disposeBag)
//            ===next(8)
//            ===next(12)
//            ===next(16)
//            ===next(20)
//            ===completed

        

        // 탭 > 레이블: "안녕 반가워"
        
        // 1. weak self
        button.rx.tap
            .subscribe { [weak self] _ in
                self?.label.text = "안녕 반가워"
            }
            .disposed(by: disposeBag)
        
        // 2. withUnretained
        button.rx.tap
            .withUnretained(self)
            .subscribe { (vc, _) in
                vc.label.text = "안녕 반가워"
            }
            .disposed(by: disposeBag)
        
        // 3. UI 바뀌는 거니까 메인 쓰레드에서 동작하는 거라고 생각할 것
        // 네트워크 통신이나 파일 다운로드 등 백그라운드 작업을 한다면?
        button.rx.tap  // 여기까지는 백그라운드일 수 있는데, 데이터 시퀀스가 흘러가면서
            .observe(on: MainScheduler.instance)  // observe 연산자를 만나고 나면, 이후 구독하는 요소들에 대해서는 메인 쓰레드에서 동작하도록 바꿔 줌
            .withUnretained(self)
            .subscribe { (vc, _) in
                vc.label.text = "안녕 반가워"
            }
            .disposed(by: disposeBag)
        
        // 4. bind: Subscribe, MainScheduler, error X
        button.rx.tap
            .withUnretained(self)
            .bind { (vc, _) in  // bind(onNext:): 무조건 메인 쓰레드에서 동작하기 때문에 1-3의 메인 쓰레드 변경 부분까지 담당
                vc.label.text = "안녕 반가워"
            }
            .disposed(by: disposeBag)
        
        // 5. operator로 데이터의 stream 조작
        button
            .rx
            .tap
            .debug()  // print 해 주는 것 뿐
            .map { "안녕 반가워" }
            .debug()
            .bind(to: label.rx.text)
            .disposed(by: disposeBag)
        
        // 6. driver traits: bind와 유사 + stream이 공유될 수 있음(리소스 낭비 방지, share())
        // share(): 불필요한 리소스 낭비가 더 생기지 않도록 스트림을 공유하는 메서드 (driver 객체: 이 share() 메서드까지 포함)
        button.rx.tap
            .map { "안녕 반가워" }
            .asDriver(onErrorJustReturn: "")  // 보통 빈 문자열로 두는 편
            .drive(label.rx.text)
            .disposed(by: disposeBag)
    }
    
    private func testRxAlamofire() {
        // 네트워크 통신 시 Success 혹은 Error 두 가지 케이스 뿐
        // 그래서 나온 네트워크 객체를 대응하는 trait: Single
        let url = APIKey.searchURL + "apple"
        request(.get, url, headers: ["Authorization": APIKey.authorization])
            .debug()
            .data()
            .debug()
            .decode(type: SearchPhoto.self, decoder: JSONDecoder())
            .debug()
//            .subscribe { value in
//                print(value)
//            }
            .subscribe(onNext: { value in
                print(value.results[0].likes)
            })  // onNext에서는 데이터를 보내고, onError에서는 에러 대응 코드
            .disposed(by: disposeBag)
    }
    
    private func testRxDataSource() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
//        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Int>>(configureCell: { dataSource, tableView, indexPath, item in
//
//            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
//            cell.textLabel?.text = "\(item)"
//            return cell
//        })
        // 전역변수로 바꾸기
        
        dataSource.titleForHeaderInSection = { dataSource, index in
            return dataSource.sectionModels[index].model
        }
        
        Observable.just([
            SectionModel(model: "title 1", items: [1, 2, 3]),
            SectionModel(model: "title 2", items: [1, 2, 3]),
            SectionModel(model: "title 3", items: [1, 2, 3])
        ])
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
}
