//
//  NewsViewController.swift
//  Week16-17
//
//  Created by SC on 2022/10/20.
//

import UIKit
import RxSwift
import RxCocoa

class NewsViewController: UIViewController {

    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var loadButton: UIButton!
    
    var viewModel = NewsViewModel()
    let disposeBag = DisposeBag()
    
    var dataSource: UICollectionViewDiffableDataSource<Int, News.NewsItem>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureHierarchy()
        configureDataSource()
        bindData()
        configureViews()
    }
    
    func bindData() {
        // MVVM - CObservable
        viewModel.dummyNews.bind { item in  // 네트워크 통신도 아니고 실패할 일이 없기 때문에 bind로만 처리
            // bind 메서드에서 closure(value)가 실행되기 때문에 처음 앱을 열었을 때도 데이터가 등록되어 보임
            var snapshot = NSDiffableDataSourceSnapshot<Int, News.NewsItem>()
            snapshot.appendSections([0])
    //        snapshot.appendItems(["아아", "따아", "아바라"])
//            snapshot.appendItems(News.items)
            snapshot.appendItems(item)
            self.dataSource.apply(snapshot, animatingDifferences: true)  // dataSource 초기화 후에 apply하기
        }
        
        // Rx
////        numberTextField.text = "3000"  // 이런 것도 데이터 하나하나로 본다 -> View Model로 보내기
//        viewModel.pageNumber.bind { value in
//            print("bind == \(value)")
//            self.numberTextField.text = value
//        }
//
//        viewModel.dummyNews
//            .withUnretained(self)
//            .bind { (vc, item) in  // 네트워크 통신도 아니고 실패할 일이 없기 때문에 bind로만 처리
//            var snapshot = NSDiffableDataSourceSnapshot<Int, News.NewsItem>()
//            snapshot.appendSections([0])
//    //        snapshot.appendItems(["아아", "따아", "아바라"])
////            snapshot.appendItems(News.items)
//            snapshot.appendItems(item)
//            vc.dataSource.apply(snapshot, animatingDifferences: true)  // dataSource 초기화 후에 apply하기
//        }
//        .disposed(by: disposeBag)
//
//        loadButton
//            .rx
//            .tap
//            .withUnretained(self)
//            .bind { (vc, _) in
//                vc.viewModel.loadSample()
//            }
//
//        resetButton
//            .rx
//            .tap
//            .withUnretained(self)
//            .bind { (vc, _) in
//                vc.viewModel.resetSample()
//            }
                
        }
    
    func configureViews() {  // 메서드로 빼서 역할 분리
        numberTextField.addTarget(self, action: #selector(numberTextFieldChanged), for: .editingChanged)
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        loadButton.addTarget(self, action: #selector(loadButtonTapped), for: .touchUpInside)
    }

    @objc func numberTextFieldChanged() {
        print(#function)
        guard let text = numberTextField.text else { return }
        viewModel.changePageNumberFormat(text: text)
    }

    @objc func resetButtonTapped() {
        print(#function)
        viewModel.resetSample()
    }

    @objc func loadButtonTapped() {
        print(#function)
        viewModel.loadSample()
    }
}

extension NewsViewController {
    func configureHierarchy() {  // addSubView, CollectionView init, SnapKit 구성 등을 이런 메서드로 한다
        collectionView.collectionViewLayout = createLayout()
        collectionView.backgroundColor = .systemGray5
    }
    
    func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, News.NewsItem> { cell, indexPath, itemIdentifier in
            var content = UIListContentConfiguration.valueCell()
            content.text = itemIdentifier.title
            content.secondaryText = itemIdentifier.body
            
            cell.contentConfiguration = content
        }
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
            
            return cell
        })
//
//        var snapshot = NSDiffableDataSourceSnapshot<Int, News.NewsItem>()
//        snapshot.appendSections([0])
////        snapshot.appendItems(["아아", "따아", "아바라"])
//        snapshot.appendItems(News.items)
//        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func createLayout() -> UICollectionViewLayout {
        let configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        return layout
    }
}
