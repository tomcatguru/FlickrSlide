//
//  MainViewController.swift
//  FlickrDemoApp
//
//  Created by Lee Kanghee on 2019. 3. 31..
//  Copyright © 2019년 Lee Kanghee. All rights reserved.
//

import UIKit
import Reachability
import Toast_Swift

final class MainViewController: ReachabilityNotifyViewController {
    //MARK: - private variable
    private let slideManager = SlideShowManager()
    
    //MARK: - iboutlets
    @IBOutlet weak var speedButton: UIButton!
    
    //MARK: - viewcontroller life-cycle funs
    override func viewDidLoad() {
        super.viewDidLoad()
        slideManager.delegate = self
    }

    //MARK: - action funcs
    @IBAction func didTapStartButton(_ sender: UIButton) {
        self.performSegue(withIdentifier: "showSlideShowSegue", sender: nil)
    }

    @IBAction func didTapSlideShowSpeed(_ sender: Any) {
        slideManager.increaseSpeed()
    }
    
    //MARK: - segue func
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSlideShowSegue" {
            if let slideShowViewController = segue.destination as? SlideShowViewController {
                slideShowViewController.slideShowSpeed = slideManager.speedInSeconds
            }
        }
    }
}

extension MainViewController: SlideShowManagerDelegate {
    func didStopSlideShow() {
        
    }

    func willStartSlideShow() {
        
    }

    func willShowNextPhoto() {
        
    }

    func didChangeSlideShowSpeed(_ speed: Int) {
        speedButton.setTitle("\(self.slideManager.speedInSeconds) x", for: .normal)
    }
}

