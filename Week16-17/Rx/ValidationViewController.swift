//
//  ValidationViewController.swift
//  Week16-17
//
//  Created by SC on 2022/10/27.
//

import UIKit

import RxSwift
import RxCocoa

class ValidationViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var validationLabel: UILabel!
    @IBOutlet weak var stepButton: UIButton!
    
    let disposeBag = DisposeBag()
    let viewModel = ValidationViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bind()
//        observableVSSubject()
    }
    
    func bind() {
        viewModel.validText  // BehaviorRelay<String>  // Output
            .asDriver()      // Driver<String>
            .drive(validationLabel.rx.text)
            .disposed(by: disposeBag)
        
//         상수로 만들기
        // validation: Observable<Bool>
        let validation = nameTextField.rx.text       // String?
                            .orEmpty                // String
                            .map { $0.count >= 8 }  // Bool
                            .share()  // share가 내부적으로 구성된 객체:  Subject, Relay

        validation
            .bind(to: stepButton.rx.isEnabled, validationLabel.rx.isHidden)  // bind 대신 subscribe를 쓰고 에러와 컴플릿을 써도 되지만 목적에 맞게 만들어진 메서드를 사용하는 것이 낫다
            .disposed(by: disposeBag)  // 자동으로 리소스 정리

        // 텍스트필드 글자 수에 따라 버튼 컬러 바꾸기
        validation
            .withUnretained(self)
            .bind { (vc, value) in
                let color: UIColor = value ? .systemPink : .lightGray
                vc.stepButton.backgroundColor = color
            }
            .disposed(by: disposeBag)  // 자동으로 리소스 정리
        
        stepButton.rx.tap
            .bind { _ in
                print("SHOW ALERT")
            }
            .disposed(by: disposeBag)
        
        
        
        
        // Stream == Sequence
        
//        nameTextField.rx.text       // String?
//            .orEmpty                // String
//            .map { $0.count >= 8 }  // Bool
//            .bind(to: stepButton.rx.isEnabled, validationLabel.rx.isHidden)  // bind 대신 subscribe를 쓰고 에러와 컴플릿을 써도 되지만 목적에 맞게 만들어진 메서드를 사용하는 것이 낫다
//            .disposed(by: disposeBag)  // 자동으로 리소스 정리
//
//        // 텍스트필드 글자 수에 따라 버튼 컬러 바꾸기
//        nameTextField.rx.text       // String?
//            .orEmpty                // String
//            .map { $0.count >= 8 }  // Bool
//            .bind { value in
//                let color: UIColor = value ? .systemPink : .lightGray
//                self.stepButton.backgroundColor = color
//            }
//            .disposed(by: disposeBag)  // 자동으로 리소스 정리
        
        
//        stepButton
//            .rx  // 네임스페이스를 통해 rx에서 활용할 수 있는 리액티브 형태로 바꿈
//            .tap
//            .subscribe { _ in
//                print("next")
//            } onError: { error in
//                print(error)
//            } onCompleted: {
//                print("complete")
//            } onDisposed: {
//                print("dispose")
//            }
//        // dispose: 리소스 정리 (쓰레기통에 버리는 것) (deinit 시점에 자동으로 정리)
//        // error나 complete가 되어도 dispose 된다 (10.24 자료 참고)
//            .disposed(by: disposeBag)
////            .disposed(by: DisposeBag())  // 빌드하자마자 dispose 됨 -> 연결이 끊어짐  // .dispose()와 동일
    }
    
    func observableVSSubject() {
        let testA = stepButton.rx.tap
            .map { "안녕하세요" }  // bind/subscribe 개수만큼 실행
//            .share()  // 3 번 실행되는 게 아니라 1 번 실행이 되는 형태로 리소스를 공유  // 옵저버블:옵저버가 1:1
            .asDriver(onErrorJustReturn: "")  // UI 특화된 요소 driver로 변경 - Stream을 공유할 수 있는 driver 객체로 바뀐다
        
        testA
//            .bind(to: validationLabel.rx.text)  // 레이블 바꾸기
            .drive(validationLabel.rx.text)
            .disposed(by: disposeBag)
        
        testA
//            .bind(to: nameTextField.rx.text)    // 텍스트 필드 텍스트 바꾸기
            .drive(nameTextField.rx.text)
            .disposed(by: disposeBag)
        
        testA
//            .bind(to: stepButton.rx.title())    // 버튼 타이틀 바꾸기
            .drive(stepButton.rx.title())
            .disposed(by: disposeBag)
        
        
        
        // just, from, of 같은 것들에 아래와 같은 것들이 다 나열되어 있다
        let sampleInt = Observable<Int>.create { observer in
            observer.onNext(Int.random(in: 1...100))
            return Disposables.create()
        }
        
        // Observable - 구독 3 개 만들기
        sampleInt.subscribe { value in
            print("sampleInt: \(value)")
        }
        .disposed(by: disposeBag)
        
        sampleInt.subscribe { value in
            print("sampleInt: \(value)")
        }
        .disposed(by: disposeBag)
        
        sampleInt.subscribe { value in
            print("sampleInt: \(value)")
        }
        .disposed(by: disposeBag)
        
        // 옵저버블:옵저버가 1:1이기 때문에 리소스 공간을 3 개 쓴다
//        sampleInt: next(18)
//        sampleInt: next(56)
//        sampleInt: next(99)
        
        
        let subjectInt = BehaviorSubject(value: 0)
        subjectInt.onNext(Int.random(in: 1...100))
        
        // BehaviorSubject - 구독 3 개 만들기
        subjectInt.subscribe { value in
            print("subjectInt: \(value)")
        }
        
        subjectInt.subscribe { value in
            print("subjectInt: \(value)")
        }
        
        subjectInt.subscribe { value in
            print("subjectInt: \(value)")
        }
        
        // Subject는 stream을 공유한다
//        subjectInt: next(76)
//        subjectInt: next(76)
//        subjectInt: next(76)
    }
}
