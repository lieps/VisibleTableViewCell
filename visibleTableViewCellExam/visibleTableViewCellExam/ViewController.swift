//
//  ViewController.swift
//  visibleTableViewCellExam
//
//  Created by lieps Yie on 2020/05/24.
//  Copyright © 2020 lieps. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var items: Array<String> = ["Cell0", "Cell1", "Cell2", "Cell3","Cell4", "Cell5", "Cell6", "Cell7", "Cell8", "Cell9"]
    
    var currentFocusIndex: IndexPath?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        self.tableView.contentInset = insets
        
        self.registerXib("VisibleTableViewCell")
    }

    private func registerXib(_ xibName: String) {
        let nibName = UINib(nibName: xibName, bundle: nil)
        self.tableView.register(nibName, forCellReuseIdentifier: xibName)
    }

}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 260
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: VisibleTableViewCell = tableView.dequeueReusableCell(withIdentifier: "VisibleTableViewCell")! as! VisibleTableViewCell
        cell.configure(items[indexPath.row])

        cell.layer.borderWidth = 0
        cell.layer.borderColor = UIColor.clear.cgColor
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("didEndDisplay: \(indexPath.row)")
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            print("scrollViewDidEndDragging")
            self.visibleCellsInfo()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewDidEndDecelerating")
        self.visibleCellsInfo()
    }
    
    func visibleCellsInfo() {
        print("-----visibleCellsInfo----- \n" +
            "VisibleRows: \(tableView.indexPathsForVisibleRows.debugDescription) \n" +
            "TableView ContentOffSet Y: \(tableView.contentOffset.y) \n" +
            "TableView contentSize height: \(tableView.contentSize.height) \n" +
            "TableView Frame Height: \(self.tableView.frame.height) \n" +
            "TableView VisibleCell Count: \(self.tableView.visibleCells.count) \n" +
            "TableView VisibleCell Info: \(self.tableView.visibleCells) \n" +
            "-------------------------- \n")
        
        print("INDEX\t\t ORIGIN.Y\t OFFSET.Y\t DIFF\t\n")
        
        var firstItem: Double = 0
        var lastItem: Double = 0
        var totalValue: Double = 0
        let cellHeight: Double = Double(260)
        
        var focusIndex: IndexPath?
        var focusRate: Double? = 0
        
        for cell in self.tableView.visibleCells.enumerated() {
            
            let diff = cell.element.frame.origin.y - tableView.contentOffset.y
            
            guard let indexPath = self.tableView.indexPathsForVisibleRows?[cell.offset] else {
                return
            }
            
            if cell.offset == 0 {
                totalValue = cellHeight - Double(abs(diff))  // 실제 보이는 첫번째 셀의 높이를 구한다.
                firstItem = floor((totalValue*100)/cellHeight) // 첫번째 셀이 몇 퍼센트 보이는지 구한다.
                print("F [\(cell.offset)] \(indexPath)\t\t \(cell.element.frame.origin.y)\t\t \(floor(tableView.contentOffset.y))\t\t \(floor(diff))\t\t \(firstItem)%")
               
                focusRate = firstItem
                focusIndex = indexPath
            }
            else if cell.offset == (tableView.visibleCells.count-1) {
                totalValue = totalValue+cellHeight
                let h = cellHeight-(totalValue - Double(tableView.frame.height))    // 실제 보이는 마지막 셀의 높이를 구한다.
                lastItem = floor((h*100)/cellHeight)   // 마지막 셀이 몇 퍼센트 보이는지 구한다.
                print("L [\(cell.offset)] \(indexPath)\t\t \(cell.element.frame.origin.y)\t\t \(floor(tableView.contentOffset.y))\t\t \(floor(diff))\t\t \(lastItem)%")
            
                if focusRate! < Double(90) {
                    focusRate = lastItem
                    focusIndex = indexPath
                }
            }
            else {
                totalValue = totalValue+cellHeight // 중간 셀들은 모두 보이니 100 퍼센트임.
                print("M [\(cell.offset)] \(indexPath)\t\t \(cell.element.frame.origin.y)\t\t \(floor(tableView.contentOffset.y))\t\t \(floor(diff))\t\t 100%")
               
                if focusRate! < Double(90) {
                    focusRate = Double(100)
                    focusIndex = indexPath
                }
            }
            
            if let idxCell: VisibleTableViewCell = self.tableView.cellForRow(at: indexPath) as? VisibleTableViewCell {
                idxCell.layer.borderWidth = 0
                idxCell.layer.borderColor = UIColor.clear.cgColor
            }
        }
        print("focus: \(String(describing: focusIndex)), \(focusRate ?? 0)%")
        
        if focusIndex == nil {
            focusIndex = IndexPath(row: 0, section: 0)
        }
        if let focusCell: VisibleTableViewCell = self.tableView.cellForRow(at: focusIndex!) as? VisibleTableViewCell {
        
            focusCell.layer.borderWidth = 1
            focusCell.layer.borderColor = UIColor.red.cgColor
            
            if (self.currentFocusIndex != focusIndex) {
                print("Previous cell: \(String(describing: currentFocusIndex))")
                if self.currentFocusIndex != nil {
                    if let idxCell: VisibleTableViewCell = self.tableView.cellForRow(at: currentFocusIndex!) as? VisibleTableViewCell {
                        idxCell.lblText.text = "out of focus"
                        print("idxCell status: \(idxCell)")
                    }
                }
                
                self.currentFocusIndex = focusIndex
                print("_Changed cell: \(String(describing: currentFocusIndex))")
                
                DispatchQueue.main.asyncAfter(deadline: .now()+0) {
                    focusCell.lblText.text = "focus on"
                }
            }
        }
    }
}
