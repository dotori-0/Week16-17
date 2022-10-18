//
//  RxCocoaExampleViewController.swift
//  Week16-17
//
//  Created by SC on 2022/10/24.
//

import UIKit

import RxCocoa
import RxSwift

class RxCocoaExampleViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var `switch`: UISwitch!
    
    @IBOutlet weak var signName: UITextField!
    @IBOutlet weak var signEmail: UITextField!
    @IBOutlet weak var signButton: UIButton!
    
    let disposeBag = DisposeBag()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setTableView()
        setPickerView()
        setSwitch()
        setSign()
        setOperator()
    }
    
    deinit {
        print("RxCocoaExampleViewController deinit")
    }
    

    func setTableView() {
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        let items = Observable.just([  // just operator
            "First Item",
            "Second Item",
            "Third Item"
        ])

        items
        .bind(to: tableView.rx.items) { (tableView, row, element) in  // 누가 구독하는지
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
            cell.textLabel?.text = "\(element) @ row \(row)"
            return cell
        }
        .disposed(by: disposeBag)
        
        // 클릭한 셀에 대한 데이터를 반환
        // didSelectRowAt으로 생각하면 됨
        tableView.rx.modelSelected(String.self)  // 여기에서 rx는 Rx 쓸 거라는 네임스페이스
//            .subscribe { value in
//                print(value)  // onNext 메서드명이 생략된 것
//            } onError: { error in
//                print(error)
//            } onCompleted: {
//                print("Completed")
//            } onDisposed: {
//                print("Disposed")
//            }
            .map { data in
                "\(data)를 클릭했습니다."  // 최종적으로 label에 바인딩될 요소
            }
            .bind(to: label.rx.text)
            .disposed(by: disposeBag)
        
        
    }

    func setPickerView() {
        let items = Observable.just([
                "영화",
                "애니메이션",
                "드라마",
                "기타"
            ])
     
        items
            .bind(to: pickerView.rx.itemTitles) { (row, element) in
                return element
            }
            .disposed(by: disposeBag)
        
        pickerView.rx.modelSelected(String.self)
//            .map { $0.description }
//            .map { "\($0)" }
            .map { $0.first }
            .bind(to: label.rx.text)
        

//            .subscribe(onNext: { value in
//                print(value)
//            })
//            .bind(to: [label.rx.text])
            .disposed(by: disposeBag)

//        pickerView.rx.modelSelected(String.self)
//            .bind(to: label.rx.text)
//            .disposed(by: disposeBag)
    }
    
    func setSwitch() {
        Observable.of(false)  // just? of?
            .bind(to: `switch`.rx.isOn)  // 옵저버로 받겠다
            .disposed(by: disposeBag)
    }
    
    func setSign() {
        // ex. 텍필1(Observable), 텍필2(Observable) > 레이블(Observer, bind)에 보여 주기
        Observable.combineLatest(signName.rx.text.orEmpty, signEmail.rx.text.orEmpty) { value1, value2 in
            return "name은 \(value1)이고, 이메일은 \(value2)입니다."
        }
        .bind(to: label.rx.text)
        .disposed(by: disposeBag)
        
        // 데이터의 흐름, Stream이 바뀌는 것을 이해하기
        signName               // UITextField
            .rx                // Reactive
            .text              // String?
            .orEmpty           // String
            .map { $0.count }  // Int
            .map { $0 < 4 }    // Bool
            .bind(to: signEmail.rx.isHidden, signButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        // 줄여서
//        signName.rx.text.orEmpty
//            .map { $0.count < 4}
//            .bind(to: signEmail.rx.isHidden)
//            .disposed(by: disposeBag)
        
        signEmail.rx.text.orEmpty
            .map { $0.count > 4 }
            .bind(to: signButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        signButton.rx.tap      // touchUpInside
            .subscribe { _ in  // 이런 상황에서는 tap 시 bind할 객체가 없기 때문에 얼럿을 띄우거나 화면 전환 등의 기능은 subscribe로 해결하는 경우가 많다
                self.showAlert()
            }
            .disposed(by: disposeBag)
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "하하하", message: nil, preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .default)
        alert.addAction(ok)
        present(alert, animated: true)
    }
    
    func setOperator() {
        
        Observable.repeatElement("Jack")  // 무수히 방출 -> 끝나지 않음         // Infinite Observable Sequence
            .take(5)                      // 5 번만 repeat하도록 stream 조절  // Finite Observable Sequence
            .subscribe { value in
                print("repeat - \(value)")  // next event, emit
            } onError: { error in
                print("repeat - \(error)")  // 이것이나
            } onCompleted: {
                print("repeat completed")   // 혹은 이것 둘 중 하나만 실행
            } onDisposed: {
                print("repeat disposed")    // dispose 되었을 때 출력되는 정도
            }
            .disposed(by: disposeBag)  // complete나 error가 되면 자동으로 dispose가 실행된다
        
        
        // 타이머처럼 1초에 하나씩 0부터 찍힌다
//        Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
        let intervalObservable = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe { value in
                print("interval - \(value)")
            } onError: { error in
                print("interval - \(error)")
            } onCompleted: {
                print("interval completed")
            } onDisposed: {
                print("interval disposed")
            }
//            .disposed(by: disposeBag)  // 끝나지 않음. deinit되지 않기 때문에 수동으로 dispose 시켜야 한다
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            intervalObservable.dispose()  // 수동으로 정지
        }
        
        
        
        let itemsA = [3.3, 4.0, 5.0, 2.0, 3.6, 4.8]
        let itemsB = [2.3, 2.0, 1.3]
        
        // just
        Observable.just(itemsA)  // 하나만 받을 수 있다
            .subscribe { value in
                print("just - \(value)")
            } onError: { error in
                print("just - \(error)")
            } onCompleted: {
                print("just completed")
            } onDisposed: {
                print("just disposed")
            }
            .disposed(by: disposeBag)

        // of
        Observable.of(itemsA, itemsB)  // 가변 매개변수 - 여러개를 묶어서 한 번에 전달이 가능
        // 배열이 하나라면 just와 of가 차이가 없지만 객체를 두 개 이상 연결할 때는 이벤트에 대한 개수가 달라질 것
            .subscribe { value in
                print("of - \(value)")
            } onError: { error in
                print("of - \(error)")
            } onCompleted: {
                print("of completed")
            } onDisposed: {
                print("of disposed")
            }
            .disposed(by: disposeBag)
        
        // from
        Observable.from(itemsA)
            .subscribe { value in
                print("from - \(value)")
            } onError: { error in
                print("from - \(error)")
            } onCompleted: {
                print("from completed")
            } onDisposed: {
                print("from disposed")
            }
            .disposed(by: disposeBag)
    }
}

