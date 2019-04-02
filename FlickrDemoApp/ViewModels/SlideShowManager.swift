//
//  SlideShowModel.swift
//  FlickrDemoApp
//
//  Created by Lee Kanghee on 2019. 3. 28..
//  Copyright © 2019년 Lee Kanghee. All rights reserved.
//

import UIKit
import Foundation

protocol SlideShowManagerDelegate: class {
    func willShowNextPhoto()
    func didChangeSlideShowSpeed(_ speed: Int)
    func willStartSlideShow()
    func didStopSlideShow()
}

class SlideShowManager {
    //MARK: - private variables
    private let speedAmount: Int = 1
    private let maxSpeed: Int = 10
    
    //MARK: - public variables
    var speedInSeconds: Int = 1 {
        didSet {
            self.delegate?.didChangeSlideShowSpeed(self.speedInSeconds)
        }
    }
    weak var delegate: SlideShowManagerDelegate?
    
    //MARK: - private variables
    private var startTime: TimeInterval?, endTime: TimeInterval?
    private var timer: Timer?

    //MARK: - public funcs
    func isStartedSlideShow() -> Bool {
        return (timer == nil) ? false : true
    }

    func startSlideShow() {
        if timer == nil {
            self.delegate?.willStartSlideShow()
            resetTimer()
        }
    }
    
    func stopSlideShow() {
        invalidateTimer()
        self.delegate?.didStopSlideShow()
    }
    
    @objc func updateTimer() {
        guard let startTime = self.startTime else {
            return
        }

        let now = CACurrentMediaTime()
        let elapsedTime = (now - startTime) * 100
        
        if Int(elapsedTime) >= (self.speedInSeconds * 100) {
            self.startTime = now
            self.delegate?.willShowNextPhoto()
        }
    }
    
    func increaseSpeed() {
        self.speedInSeconds = (self.speedInSeconds >= self.maxSpeed) ? speedAmount : self.speedInSeconds + speedAmount
    }

    func movedToNextSlide() {
        if isStartedSlideShow() {
            invalidateTimer()
            resetTimer()
        }
    }
    
    //MARK: - private funcs
    private func resetTimer() {
        let timer = Timer(timeInterval: 0.1,
                          target: self,
                          selector: #selector(updateTimer),
                          userInfo: nil,
                          repeats: true)
        RunLoop.current.add(timer, forMode: .common)
        timer.tolerance = 0.1
        self.timer = timer
        self.startTime = CACurrentMediaTime()
    }
    
    private func invalidateTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
}
