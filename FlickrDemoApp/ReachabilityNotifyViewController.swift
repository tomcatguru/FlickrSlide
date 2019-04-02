//
//  ReachabilityNotifyViewController.swift
//  FlickrDemoApp
//
//  Created by Lee Kanghee on 2019. 3. 31..
//  Copyright © 2019년 Lee Kanghee. All rights reserved.
//

import UIKit
import Reachability
import Toast_Swift

class ReachabilityNotifyViewController: UIViewController {
    //MARK: - private variables
    private let reachability = Reachability()!
    
    //MARK: - viewcontroller life-cycle funs
    override func viewDidLoad() {
        super.viewDidLoad()
        reachability.whenUnreachable = { [weak self] _ in
            guard let weakSelf = self else {
                return
            }
            weakSelf.view.makeToast("Unable to use network")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do {
            try reachability.startNotifier()
        } catch {
            self.view.makeToast("Unable to start notifier")
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        reachability.stopNotifier()
    }
}
