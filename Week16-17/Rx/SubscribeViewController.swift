//
//  SubscribeViewController.swift
//  Week16-17
//
//  Created by SC on 2022/10/26.
//

import UIKit

import RxCocoa
import RxSwift

class SubscribeViewController: UIViewController {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var label: UILabel!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
            .bind { (vc, _) in  // bind(onNext:): 무조건 메인 쓰레드에서 동작하기 때문에 1-3의 메인 쓰레드 변경 부분까지 담당하고 있다?? ☘️
                vc.label.text = "안녕 반가워"
            }
            .disposed(by: disposeBag)
        
        // 5. operator로 데이터의 stream 조작
        button
            .rx
            .tap
            .map { "안녕 반가워" }
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
    

}
