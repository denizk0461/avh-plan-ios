//
//  LoginViewController.swift
//  AvH Plan
//
//  Created by Deniz Duezgoeren on 21.09.19.
//  Copyright © 2019 Deniz Duezgoeren. All rights reserved.
//

import UIKit
import WebKit

class LoginViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var webView: WKWebView!
    let prefs = UserDefaults.standard
    let request = URLRequest(url: URL(string: "https://307.joomla.schule.bremen.de/index.php/component/users/#top")!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.reloadLoginPage(in: webView)
        self.webView.navigationDelegate = self
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        let page = webView.url?.absoluteString
        if (page != "https://307.joomla.schule.bremen.de/index.php/component/users/profile?Itemid=171"
            && page != "https://307.joomla.schule.bremen.de/index.php/component/users/#top"
            && page != "https://307.joomla.schule.bremen.de/index.php/component/users/?task=user.login&Itemid=171") {
            self.reloadLoginPage(in: webView)
        }
    }
        
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
            for cookie in cookies {
                if cookie.name == "joomla_user_state" && cookie.value == "logged_in" {
                    self.success()
                }
            }
        }
    }
    
    private func reloadLoginPage(in webView: WKWebView) {
        self.webView.load(request)
    }
    
    private func success() {
        self.prefs.set(true, forKey: "logged_in")
        if let s = storyboard?.instantiateViewController(withIdentifier: "FirstTime") as? UINavigationController {
            self.present(s, animated: true)
        }
    }
}
