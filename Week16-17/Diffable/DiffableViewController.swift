//
//  DiffableCollectionViewController.swift
//  Week16-17
//
//  Created by SC on 2022/10/19.
//

import UIKit
import Kingfisher

private let reuseIdentifier = "Cell"

class DiffableViewController: UIViewController {


    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
//    var list = ["아이폰", "아이패드", "에어팟", "맥북", "애플워치"]
    
    var viewModel = DiffableViewModel()
    
//    private var cellRegistration: UICollectionView.CellRegistration<UICollectionViewListCell, String>!
//    private var dataSource: UICollectionViewDiffableDataSource<Int, String>!  // Int: Section, String: 셀에 들어갈 데이터 타입
    private var dataSource: UICollectionViewDiffableDataSource<Int, SearchResult>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        APIService.searchPhoto(query: "apple")

        searchBar.delegate = self
        
        collectionView.collectionViewLayout = createLayout()
        configureDataSource()
        collectionView.delegate = self  // Diffable은 데이터소스만 있기 때문에 delegate는 필요
        
        
        viewModel.photoList.bind { photo in
            var snapshot = NSDiffableDataSourceSnapshot<Int, SearchResult>()
            snapshot.appendSections([0])
            snapshot.appendItems(photo.results)
            self.dataSource.apply(snapshot)
        }
    }

}

extension DiffableViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let item = list[indexPath.item]
//        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
                
//        let alert = UIAlertController(title: item, message: "클릭!", preferredStyle: .alert)
//        let ok = UIAlertAction(title: "확인", style: .cancel)
//        alert.addAction(ok)
//        present(alert, animated: true)
    }
}

extension DiffableViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        var snapshot = dataSource.snapshot()
//        snapshot.appendItems([searchBar.text!])
//        dataSource.apply(snapshot, animatingDifferences: true)
        viewModel.requestSearchPhoto(query: searchBar.text!)
    }
}

extension DiffableViewController {
    private func createLayout() -> UICollectionViewLayout {
        let config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        return layout
    }
    
    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, SearchResult>(handler: { cell, indexPath, itemIdentifier in
            var content = UIListContentConfiguration.valueCell()
            content.text = "\(itemIdentifier.likes)"
//            content.secondaryText = "\(itemIdentifier.count)"
            
            
            // String > URL > Data > Image
            DispatchQueue.global().async {  // 다운로드를 받는 동안 다른 작업을 할 수 있게 백그라운드 쓰레드에서 네트워크 통신 작업
                let url = URL(string: itemIdentifier.urls.thumb)!
                let data = try? Data(contentsOf: url)
                
                DispatchQueue.main.async {  // UI 업데이트 시 main thread에서
                    content.image = UIImage(data: data!)
                    cell.contentConfiguration = content
                }
                
            }
            
//            cell.contentConfiguration = content  // 이미지 다운, 변환하는 시간보다 더 빨리 실행되기 때문에 global().async 안의 main.async로 이동
            
            var background = UIBackgroundConfiguration.listPlainCell()
            background.strokeWidth = 2
            background.strokeColor = .systemMint
            cell.backgroundConfiguration = background
        })
        
        // collectionView.dataSource = self  // 이런 코드도 필요없음

        // numberOfItemsInSection, cellForItemAt 대신
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
            
            return cell
        })
        
//        // Initalize
//        var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
//        snapshot.appendSections([0])
//        snapshot.appendItems(list)
//
//        dataSource.apply(snapshot)
    }
}
