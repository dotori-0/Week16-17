//
//  NewsViewController.swift
//  Week16-17
//
//  Created by SC on 2022/10/20.
//

import UIKit

class NewsViewController: UIViewController {

    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var loadButton: UIButton!
    
    var viewModel = NewsViewModel()
    
    var dataSource: UICollectionViewDiffableDataSource<Int, News.NewsItem>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureHierarchy()
        configureDataSource()
        bindData()
        configureViews()
    }
    
    func bindData() {
//        numberTextField.text = "3000"  // 이런 것도 데이터 하나하나로 본다 -> View Model로 보내기
        viewModel.pageNumber.bind { value in
            print("bind == \(value)")
            self.numberTextField.text = value
        }
        
        viewModel.dummyNews.bind { item in
            var snapshot = NSDiffableDataSourceSnapshot<Int, News.NewsItem>()
            snapshot.appendSections([0])
    //        snapshot.appendItems(["아아", "따아", "아바라"])
//            snapshot.appendItems(News.items)
            snapshot.appendItems(item)
            self.dataSource.apply(snapshot, animatingDifferences: true)  // dataSource 초기화 후에 apply하기
        }
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
