//
//  SettingsViewController.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/5/3.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    struct Row {
        let title: String
        let detail: String?
    }
    
    var data: [Row] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "設定"
        
        data = [Row(title: "聯絡我們", detail: "justin.tseng.developer@gmail.com"),
                Row(title: "隱私權政策", detail: nil)]
        
        
    }
    
    func openURL(_ urlString: String) {
        // 檢查網址是否有效
        guard let url = URL(string: urlString) else {
            print("無效的網址")
            return
        }
        
        // 檢查應用程序是否能夠打開該網址
        if UIApplication.shared.canOpenURL(url) {
            // 嘗試打開網址
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            print("無法打開網址")
        }
    }
    
    func copyTextToClipboard(_ text: String) {
        // 將文字複製到系統剪貼簿
        UIPasteboard.general.string = text
        print("文字已複製到剪貼簿")
    }
}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingCell.reuseIdentifier, for: indexPath) as! SettingCell
        
        cell.nameLabel.text = data[indexPath.row].title
        cell.detailLabel.text = data[indexPath.row].detail
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0  {
            guard let detail = data[indexPath.row].detail else { return }
            copyTextToClipboard(detail)
            
        } else if indexPath.row == 1 {
            openURL("https://www.privacypolicies.com/live/532490ef-4e2c-48ef-8d22-2aac161bf162")
            
        }
    }
}
