//
//  TopicDetailViewController.swift
//  CNodeJS-Swift
//
//  Created by h on 2018/6/30.
//  Copyright © 2018年 H. All rights reserved.
//

import UIKit
import Kingfisher
import SnapKit
import Moya
import WebKit
import SwiftyJSON
import YBImageBrowser

class TopicDetailWebViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {
    
    var provider = MoyaProvider<CNodeService>()
    
    var topic_id: String!
    var detail_reply_id: String?
    var detail_reply_loginname: String?
    
    var refreshControl = UIRefreshControl()
    
    lazy var webView: WKWebView = {
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        configuration.userContentController = WKUserContentController()
        configuration.userContentController.add(self, name: "AppModel")
        
        var webView = WKWebView(frame: .zero, configuration: configuration)
//        webView.layer.borderColor = UIColor.red.cgColor
//        webView.layer.borderWidth = 1
//        webView.scrollView.bounces = true
        webView.isOpaque = false
        webView.scrollView.alwaysBounceVertical = true
        webView.navigationDelegate = self
        webView.loadHTMLString(TOPICDETAILHTML, baseURL: Bundle.main.resourceURL)
        return webView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("topic_detail", comment: "")
        
        //添加菜单
        let menuButton = UIButton()
        menuButton.contentMode = .center
        menuButton.setImage(UIImage(named: "baseline_more_vert_white_24pt"), for: UIControlState.normal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: menuButton)
        menuButton.addTarget(self, action: #selector(TopicDetailWebViewController.menuClick), for: .touchUpInside)

        //给scrollView添加下拉刷新
        self.refreshControl.addTarget(self, action: #selector(TopicDetailWebViewController.fetch), for: .valueChanged)
        webView.scrollView.addSubview(refreshControl)
        
        // 这个设置没用，第一次加载就是黑色的，加载完成之后再手动刷新颜色就正常了，不清楚到底是为啥
//        self.refreshControl.tintColor = AppColor.colors.titleColor
        self.refreshControl.beginRefreshing()

        addSubView()
        addConstraints()
        
        self.themeChangedHandler = {[weak self] (style) -> Void in
            self?.view.backgroundColor = AppColor.colors.backgroundColor
            self?.navigationController?.navigationBar.tintColor = AppColor.colors.navigationBackgroundColor
            self?.webView.backgroundColor = AppColor.colors.backgroundColor
            self?.webView.scrollView.backgroundColor = AppColor.colors.backgroundColor
            self?.refreshControl.tintColor = AppColor.colors.titleColor
        }
    }
    
    func addSubView() {
        self.view.addSubview(webView)
    }
    
    func addConstraints() {
        webView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(0)
            make.top.equalTo(NavigationBarHeight)
        }
    }
    
    @objc func fetch() {
        //刷新页面
        provider.request(.topicDetail(id: self.topic_id)) { (res) in
            switch res {
            case .success(let response):
                self.refreshControl.endRefreshing()
                var topicJson = JSON(response.data)
//                NSLocalizedString("topic_reply", comment: "")
                
                var _locale = Dictionary<String, String>()
                _locale = [
                    "tab_good": NSLocalizedString("tab_good", comment: ""),
                    "tab_share": NSLocalizedString("tab_share", comment: ""),
                    "tab_dev": NSLocalizedString("tab_dev", comment: ""),
                    "tab_ask": NSLocalizedString("tab_ask", comment: ""),
                    "tab_blog": NSLocalizedString("tab_blog", comment: ""),
                    "tab_job": NSLocalizedString("tab_job", comment: ""),
                    "topic_visit_count": NSLocalizedString("topic_visit_count", comment: ""),
                    "replies": NSLocalizedString("replies", comment: ""),
                    "reply_floor": NSLocalizedString("reply_floor", comment: ""),
                    "reply_no_more": NSLocalizedString("reply_no_more", comment: ""),
                    "reply_author": NSLocalizedString("reply_author", comment: ""),
                    "time_i18n": NSLocalizedString("time_i18n", comment: ""),
                ]
                topicJson["data"]["locale"] = JSON(_locale)
                topicJson["data"]["_theme"] = JSON(AppColor.sharedInstance.style)
                
                var topicJsonStr = topicJson.rawString();
                topicJsonStr = topicJsonStr?.replacingOccurrences(of: "\n", with: "")
                topicJsonStr = topicJsonStr?.replacingOccurrences(of: "\\/\\/static.cnodejs.org", with: "https:\\/\\/static.cnodejs.org")
                self.webView.evaluateJavaScript("init(\(topicJsonStr!))", completionHandler: { (res, err) in
                    //print(11, res, err)
                })
            case .failure(let error):
                UIAlertController.showAlert(message: error.errorDescription!)
            }
        }
    }
    
    @objc func menuClick() {
        let topicAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//        let alertController = UIAlertController(title: "Hello World", message: "WebView加载HTML才是王道", preferredStyle: .actionSheet)
        topicAlertController.addAction(UIAlertAction(title: NSLocalizedString("topic_reply", comment: ""), style: .default, handler: self.replyHandler))
        topicAlertController.addAction(UIAlertAction(title: NSLocalizedString("topic_share", comment: ""), style: .default, handler: self.shareHandler))
        topicAlertController.addAction(UIAlertAction(title: NSLocalizedString("topic_collect", comment: ""), style: .default, handler: self.collectHandler))
        topicAlertController.addAction(UIAlertAction(title: NSLocalizedString("topic_report", comment: ""), style: .default, handler: self.reportHandler))
        topicAlertController.addAction(UIAlertAction(title: NSLocalizedString("topic_cancel", comment: ""), style: .cancel, handler: nil))
        self.present(topicAlertController, animated: true, completion: nil)
        
    }
    
    @objc func replyClick() {
        let replyAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//        let alertController = UIAlertController(title: "Hello World", message: "你想干点啥", preferredStyle: .actionSheet)
        replyAlertController.addAction(UIAlertAction(title: NSLocalizedString("topic_reply", comment: ""), style: .default, handler: self.replyHandler))
        replyAlertController.addAction(UIAlertAction(title: NSLocalizedString("topic_up", comment: ""), style: .default, handler: self.upHandler))
        replyAlertController.addAction(UIAlertAction(title: NSLocalizedString("topic_report", comment: ""), style: .default, handler: self.reportHandler))
        replyAlertController.addAction(UIAlertAction(title: NSLocalizedString("topic_cancel", comment: ""), style: .cancel, handler: nil))
        self.present(replyAlertController, animated: true, completion: nil)
        
    }
    
    func upHandler(alert: UIAlertAction) {
        if UserDefaults.standard.string(forKey: "token") != nil {
            self.view.makeToastActivity(.center)
            provider.request(.up(self.detail_reply_id!, UserDefaults.standard.string(forKey: "token")!)) { (res) in
                switch res {
                case .success(_):
                    self.view.hideToastActivity()
                    self.navigationController?.view.makeToast(NSLocalizedString("alert_success", comment: ""))
                case .failure(let error):
                    UIAlertController.showAlert(message: error.errorDescription!)
                }
            }
        } else {
            self.view.makeToast(NSLocalizedString("settings_login_tip", comment: ""))
        }
    }
    
    func collectHandler(alert: UIAlertAction) {
        if UserDefaults.standard.string(forKey: "token") != nil {
            self.view.makeToastActivity(.center)
            provider.request(.favorite(UserDefaults.standard.string(forKey: "token")!, self.topic_id)) { (res) in
                switch res {
                case .success(_):
                    self.view.hideToastActivity()
                    self.navigationController?.view.makeToast(NSLocalizedString("alert_success", comment: ""))
                case .failure(let error):
                    UIAlertController.showAlert(message: error.errorDescription!)
                }
            }
        } else {
            self.view.makeToast(NSLocalizedString("settings_login_tip", comment: ""))
        }
    }
    
    func reportHandler(alert: UIAlertAction) {
        if UserDefaults.standard.string(forKey: "token") != nil {
            self.navigationController?.view.makeToast(NSLocalizedString("alert_success", comment: ""))
        } else {
            self.view.makeToast(NSLocalizedString("settings_login_tip", comment: ""))
        }
    }
    
    func shareHandler(alert: UIAlertAction) {
        let shareUrl = URL.init(string: "\(BASE_URL)/topic/\(self.topic_id!)")
        let shareArr = [shareUrl!]
        let activityController = UIActivityViewController.init(activityItems: shareArr, applicationActivities: nil)
        self.present(activityController, animated: true, completion: nil)
    }
    
    func replyHandler(alert: UIAlertAction) {
        if UserDefaults.standard.string(forKey: "token") != nil {
            let addReplyViewController = AddReplyViewController();
            addReplyViewController.topic_id = self.topic_id
            addReplyViewController.reply_id = detail_reply_id
            addReplyViewController.detail_reply_loginname = detail_reply_loginname
            // 回复成功被调用用来显示toast
            addReplyViewController.reply_success = {[weak self] in
                self?.navigationController?.view.makeToast(NSLocalizedString("alert_success", comment: ""))
                self?.refreshControl.beginRefreshing()
                self?.fetch()
            }
            let navigationController = UINavigationController(rootViewController: addReplyViewController)
            present(navigationController, animated: true, completion: nil)
        } else {
            self.view.makeToast(NSLocalizedString("settings_login_tip", comment: ""))
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        fetch();
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let msg = JSON(parseJSON: message.body as! String)
        if (msg["type"] == "click_reply") {
            detail_reply_id = msg["reply_id"].rawString()
            detail_reply_loginname = msg["loginname"].rawString()
            replyClick()
        } else if (msg["type"] == "to_user_center") {
            let userCenterViewController = UserCenterViewController()
            userCenterViewController.type = 1
            userCenterViewController.loginname = msg["loginname"].rawString()
            self.navigationController?.pushViewController(userCenterViewController, animated: true)
        } else if (msg["type"] == "click_a") {
            var href = msg["href"].rawString()
//            print(href)
            
            let urlComponents = URLComponents(string: href!)!
//            if let scheme = urlComponents.scheme {
//                print("scheme: \(scheme)")
//            }
//            if let user = urlComponents.user {
//                print("user: \(user)")
//            }
//            if let password = urlComponents.password {
//                print("password: \(password)")
//
//            }
//            if let host = urlComponents.host {
//                print("host: \(host)")
//
//            }
//            if let port = urlComponents.port {
//                print("port: \(port)")
//
//            }
//            print("path: \(urlComponents.path)")
//            if let query = urlComponents.query {
//                print("query: \(query)")
//            }
//            if let queryItems = urlComponents.queryItems {
//                print("queryItems: \(queryItems)")
//                for (index, queryItem) in queryItems.enumerated() {
//                    print("第\(index)个queryItem name:\(queryItem.name)")
//                    if let value = queryItem.value {
//                        print("第\(index)个queryItem value:\(value)")
//                    }
//                }
//            }
            
            if urlComponents.scheme != nil && urlComponents.host != "cnodejs.org" {
                UIApplication.shared.open(URL(string: href!)!, options: [:], completionHandler: nil)
            } else if urlComponents.scheme == nil && urlComponents.path.contains("/user") {
                href = href?.replacingOccurrences(of: "/user/", with: "")
                let userCenterViewController = UserCenterViewController()
                userCenterViewController.type = 1
                userCenterViewController.loginname = href
                self.navigationController?.pushViewController(userCenterViewController, animated: true)
            } else if urlComponents.scheme != nil && urlComponents.host == "cnodejs.org" {
                let _topic_id = urlComponents.path.replacingOccurrences(of: "/topic/", with: "")
                let topicDetailWebViewController = TopicDetailWebViewController()
                topicDetailWebViewController.topic_id = _topic_id
                self.navigationController?.pushViewController(topicDetailWebViewController, animated: true)
            }
        } else if (msg["type"] == "click_img") {
            let img_src = msg["img_src"].rawString()
            let imageBrowser = YBImageBrowser()
            let cellData = YBImageBrowseCellData()
            cellData.url = URL(string: img_src!)
            imageBrowser.dataSourceArray = [cellData]
            imageBrowser.show()
        }
    }
}
