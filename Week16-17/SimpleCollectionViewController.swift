//
//  SimpleCollectionViewController.swift
//  Week16-17
//
//  Created by SC on 2022/10/18.
//

import UIKit

struct User: Hashable {
    let id = UUID().uuidString  // Hashable
    let name: String            // Hashable
    let age: Int                // Hashable
  
    // Xcode 14부터는 class init 구문 자동완성
//    init(name: String, age: Int) {
//        self.name = name
//        self.age = age
//    }
}

class SimpleCollectionViewController: UICollectionViewController {
    
//    var list = ["닭곰탕", "삼계탕", "들기름김", "삼분카레", "콘소메 치킨"]
    var list = [
        User(name: "뽀로로", age: 3),
        User(name: "뽀로로", age: 3),
        User(name: "에디", age: 13),
        User(name: "해리포터", age: 33),
        User(name: "도라에몽", age: 5)
    ]
    
    // https://developer.apple.com/documentation/uikit/uicollectionview/cellregistration
    // cellForItemAt 전에 생성되어야 한다 -> register 코드와 유사한 역할
//    var cellRegistration: UICollectionView.CellRegistration<UICollectionViewListCell, String>!
    var cellRegistration: UICollectionView.CellRegistration<UICollectionViewListCell, User>!
    
    var dataSource: UICollectionViewDiffableDataSource<Int, User>!
    
    var hello: (() -> Void)!
    
    func welcome() {
        print("hello")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(hello)

//        hello = welcome  // welcome =/= welcome() 함수 이름만 넣어 준 것임 (함수 호출 연산자 X)  (일급 객체이기 때문에 가능한 것이긴 하다)
        hello = {
            print("hello")
        }  // 익명 함수 넣기  // 함수 실행은 아니지만 함수를 가지고 있음
        
        print(hello)

        hello()
        
        
        collectionView.collectionViewLayout = createLayout()
        
        print(cellRegistration)
        
        // 1. Identifier 2. struct
        cellRegistration = UICollectionView.CellRegistration { cell, indexPath, itemIdentifier in
            // 데이터들을 다 여기에서 설정 (셀의 디자인적인 처리나 데이터 처리 같은 것들도 거의 다 담당)
            
//            var content = cell.defaultContentConfiguration()
            var content = UIListContentConfiguration.valueCell()
            
//            content.text = itemIdentifier
            content.text = itemIdentifier.name
            content.textProperties.color = .systemIndigo
            
//            content.secondaryText = "안녕하세용"
            content.secondaryText = "\(itemIdentifier.age)살"
            content.prefersSideBySideTextAndSecondaryText = false
            content.textToSecondaryTextVerticalPadding = 20
            
//            content.image = UIImage(systemName: "person.fill")
            content.image = itemIdentifier.age < 8 ? UIImage(systemName: "person.fill") : UIImage(systemName: "star")
            content.imageProperties.tintColor = .systemPink
            
            cell.backgroundConfiguration?.backgroundColor = .yellow
            
            print("🐣 setup")  // 셀 갯수만큼 호출됨
            cell.contentConfiguration = content
            // contentConfiguration: UIContentConfiguration (프로토콜)
            // content: UIListContentConfiguration (구조체)(UIContentConfiguration 채택)
            
            var backgroundConfig = UIBackgroundConfiguration.listGroupedCell()
            backgroundConfig.backgroundColor = .systemGray6
            backgroundConfig.cornerRadius = 10
            backgroundConfig.strokeWidth = 2
            backgroundConfig.strokeColor = .systemPink
            
            cell.backgroundConfiguration = backgroundConfig
        }
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueConfiguredReusableCell(using: self.cellRegistration, for: indexPath, item: itemIdentifier)
            return cell
        })
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, User>()
        snapshot.appendSections([0])
        snapshot.appendItems(list)
        dataSource.apply(snapshot)
        
        print(cellRegistration)
    }
    
//    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return list.count
//    }
//
//    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let item = list[indexPath.item]
//        // <#T##UICollectionView.CellRegistration<Cell, Item>#> 어떤 셀을 쓸 건지와 셀에 어떤 데이터가 들어갈지
//        let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)  // 여기에서 넘겨준 item을
//
//        return cell
//    }
}

extension SimpleCollectionViewController {
    private func createLayout() -> UICollectionViewLayout {  // layout은 UICollectionViewCompositionalLayout이지만, collectionView.collectionViewLayout가 UICollectionViewLayout이기 때문에 반환도 이 타입으로 하는 것이 더 적절
        // iOS 14+ 컬렉션뷰를 테이블뷰 스타일처럼 사용 가능 (List Configuration)
        // 컬렉션뷰 스타일 (컬렉션뷰 셀과는 관계가 X)
        var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        configuration.showsSeparators = false
        configuration.backgroundColor = .systemMint
        
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        return layout
    }
}
