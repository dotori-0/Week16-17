//
//  ViewController.swift
//  Week16-17
//
//  Created by SC on 2022/10/18.
//

import UIKit

class SimpleTableViewController: UITableViewController {
    
    let list = ["슈비버거", "프랭크", "자갈치", "고래밥"]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "")!  // 시스템 셀을 사용한다면 for: IndexPath 구문까지는 필요 없으니까 이런 식의 형태로 구현이 가능
//
//        cell.textLabel?.text = list[indexPath.row]
        
        let cell = UITableViewCell()
        var content = cell.defaultContentConfiguration()
        content.text = list[indexPath.row]  // textLabel
        content.secondaryText = "안녕하세요"   // detailTextLabel
        
        cell.contentConfiguration = content
        
        return cell
    }
}

