//
//  UserViewController.swift
//  CNodeJS-Swift
//
//  Created by H on 2018/6/29.
//  Copyright © 2018年 H. All rights reserved.
//

import UIKit

class UserViewController: UITableViewController {
    
    lazy var headerView: UserHeaderTableViewCell = {
        var cell = UserHeaderTableViewCell()
        cell.type = 0
        cell.scanQrCodeViewController = { [weak self] vc in
            self?.navigationController?.pushViewController(vc!, animated: true)
        }
        cell.startReloadDataRefreshing = { [weak self] in
            self?.view.makeToastActivity(.center)
        }
        cell.endReloadDataRefreshing = { [weak self] in
            self?.view.hideToastActivity()
        }
        cell.updateMenuStatus = { [weak self] in
            self?.tableView.reloadData()
        }
        cell.toastMessage = {[weak self] msg in
            self?.navigationController?.view.makeToast(msg)
        }
        return cell
    }()
    
    var data = [
        ("", []),
        ("", [
            ("baseline_account_circle_black_24pt",NSLocalizedString("my_user_center", comment: "")),
//            ("baseline_view_list_black_24pt","我的话题"),
//            ("baseline_reply_all_black_24pt","我的回复"),
            ("baseline_collections_bookmark_black_24pt",NSLocalizedString("my_collect", comment: "")),
//            ("baseline_settings_black_24pt","设置")
        ]),
        ("", [
            ("baseline_code_black_24pt",NSLocalizedString("my_open_source", comment: "")),
            ("baseline_bug_report_black_24pt",NSLocalizedString("my_issues", comment: ""))
        ]),
        ("", [("baseline_warning_white_24pt",NSLocalizedString("my_logout", comment: ""))])
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.title = NSLocalizedString("tablayout_my", comment: "")
        self.view.backgroundColor = UIColor(CNodeColor.grayColor)
        
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.tintColor = .white
        
        self.tableView.addSubview(headerView)
    
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "userCell")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "logoutCell")
        
        let footerView = UIView()
        footerView.backgroundColor = UIColor.clear
        self.tableView.tableFooterView = footerView
        
        // 加载当前用户信息
        self.headerView.bind();
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return headerView
        } else {
            return UIView()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return [200, 0, 20, 20][section]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].1.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return UITableViewCell()
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)
            if indexPath.section == 3 {
                cell.textLabel?.textColor = UIColor.red
                cell.textLabel?.textAlignment = .center
                if UserDefaults.standard.string(forKey: "token") == nil {
                    cell.isUserInteractionEnabled = false
                } else {
                    cell.isUserInteractionEnabled = true
                }
            }
            cell.imageView?.tintColor = UIColor.black
            cell.textLabel?.text = data[indexPath.section].1[indexPath.row].1
            if indexPath.section != 3 {
                cell.imageView?.image = UIImage(named: data[indexPath.section].1[indexPath.row].0)
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if UserDefaults.standard.string(forKey: "token") != nil {
            let menuName = data[indexPath.section].1[indexPath.row].1
            if menuName == NSLocalizedString("my_user_center", comment: "") {
                let userCenterViewController = UserCenterViewController()
                userCenterViewController.type = 0
                userCenterViewController.loginname = UserDefaults.standard.string(forKey: "loginname")
                self.navigationController?.pushViewController(userCenterViewController, animated: true)
            } else if menuName == NSLocalizedString("my_collect", comment: "") {
                let collectVC = CollectTableViewController()
                self.navigationController?.pushViewController(collectVC, animated: true)
            } else if menuName == NSLocalizedString("my_open_source", comment: "") {
                UIApplication.shared.open(URL(string: "https://github.com/tomoya92/CNodeJS-Swift")!, options: [:]) { (success) in
                    //打开浏览器成功了，做点其它的东东
                }
            } else if menuName == NSLocalizedString("my_issues", comment: "") {
                UIApplication.shared.open(URL(string: "https://github.com/tomoya92/CNodeJS-Swift/issues")!, options: [:]) { (success) in
                    //打开浏览器成功了，做点其它的东东
                }
            } else if menuName == NSLocalizedString("my_logout", comment: "") {
                UIAlertController.showConfirm(message: NSLocalizedString("my_logout_tip", comment: "")) { (_) in
                    let domain = Bundle.main.bundleIdentifier!
                    UserDefaults.standard.removePersistentDomain(forName: domain)
                    UserDefaults.standard.synchronize()
                    self.headerView.unbind()
                    self.tableView.reloadData()
                }
            }
        } else {
            UIAlertController.showAlert(message: NSLocalizedString("my_login_tip", comment: ""))
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
