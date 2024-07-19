//
//  TagSettingViewController.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/7/19.
//

import UIKit

class TagSettingViewController: UIViewController, StoryboardGenerated {
    
    static var storyboardName: String = K.Storyboard.main
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.register(UINib(nibName: "TagTestingCell", bundle: nil), forCellReuseIdentifier: "TagTestingCell")
        tableView.dataSource = self
    }
}

extension TagSettingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TagTestingCell", for: indexPath) as! TagTestingCell
        
        cell.reload =  {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
        
        cell.beginUpdate = {
            self.tableView.beginUpdates()
        }
        
        cell.endUpdate = {
            self.tableView.endUpdates()
        }
        
        return cell
    }
}

struct TagSetting {
    
    protocol PracticeModelProtocol {
        var isOpen: Bool { get set }
    }
    
    enum PracticeMode {
        case clozeWord(ClozeWord)
        case clozeSentence
    }
    
    struct ClozeWord: PracticeModelProtocol {
        var isOpen: Bool
    }
    
    var tagColor: UIColor
    
    var practiceModes: [[PracticeMode]]
}
