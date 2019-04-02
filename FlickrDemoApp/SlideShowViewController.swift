//
//  SlideShowViewController.swift
//  FlickrDemoApp
//
//  Created by Lee Kanghee on 2019. 3. 31..
//  Copyright © 2019년 Lee Kanghee. All rights reserved.
//

import UIKit
import Toast_Swift
import Kingfisher

final class SlideShowViewController: ReachabilityNotifyViewController {
    //MARK: - private variables
    #if DEBUG
    private let isDebug = true
    #else
    private let isDebug = false
    #endif
    
    private let viewModel = FlickrViewModel()
    private let defaultBottomViewHeight: CGFloat = 60.0
    private let imageTransitionDuration: TimeInterval = 1.0
    private let slideShowChangeAnimationDuration: TimeInterval = 0.5
    
    //MARK: - public variables
    var slideShowSpeed: Int {
        get {
            return viewModel.speedInSeconds
        }
        set {
            viewModel.speedInSeconds = newValue
        }
    }

    //MARK: - iboutlets
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nextPhotoButton: UIButton!
    @IBOutlet weak var previousPhotoButton: UIButton!
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    @IBOutlet weak var slideShowSpeedButton: UIButton?
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var debugIndexLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    //MARK: - viewcontroller life-cycle funs
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicatorView.startAnimating()
        bottomViewHeight.constant = defaultBottomViewHeight
        viewModel.delegate = self
        viewModel.fetchPhotos()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        photoImageView.isUserInteractionEnabled = true
        photoImageView.addGestureRecognizer(tapGestureRecognizer)
        self.debugIndexLabel.isHidden = !isDebug
        self.changeSlideShowSpeed(viewModel.speedInSeconds)
    }
    
    //MARK: - action funs
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        if let _ = tapGestureRecognizer.view as? UIImageView {
            if self.viewModel.isStartedSlideShow() {
                self.viewModel.stopSlideShow()
            } else {
                self.viewModel.startSlideShow()
            }
        }
    }

    @IBAction func didTapNextButton(_ sender: UIButton) {
        self.showNextPhoto()
    }

    @IBAction func didTapPreviousButton(_ sender: UIButton) {
        self.showPreviousPhoto()
    }
    
    @IBAction func didTapSlideShowSpeedButton(_ sender: UIButton) {
        viewModel.increaseSpeed()
    }
    
    //MARK: - private funcs
    private func animateImageView(_ url: URL?) {
        photoImageView.kf.setImage(with: url,
                                   options: [.transition(ImageTransition.fade(imageTransitionDuration)),
                                             .forceTransition,
                                             .keepCurrentImageWhileLoading],
                                   completionHandler: { [weak self] (image, error, cacheType, imageURL) in
            guard let weakSelf = self, error == nil else {
                return
            }

            weakSelf.viewModel.movedToNextSlide()
        })
    }
    
    private func showNextPhoto() {
        guard let nextPhoto = self.viewModel.nextPhoto(), let urlString = nextPhoto.imageURL else {
            self.view.makeToast("Could not load next photo")
            return
        }
        
        showDebugIndexIfNeeded()
        animateImageView(URL(string: urlString))
        self.viewModel.fetchPhotosIfNeeded()
    }
    
    private func showPreviousPhoto() {
        guard let previousPhoto = self.viewModel.previousPhoto(), let urlString = previousPhoto.imageURL else {
            self.view.makeToast("Could not load previous photo")
            return
        }
        
        showDebugIndexIfNeeded()
        animateImageView(URL(string: urlString))
    }
    
    private func showDebugIndexIfNeeded() {
        if isDebug {
            self.debugIndexLabel.text = "\(viewModel.currentItemIndex) / \(self.viewModel.totalCount)"
        }
    }
    
    private func changeSlideShowSpeed(_ speed: Int) {
        slideShowSpeedButton?.setTitle("\(speed) x", for: .normal)
    }
}

extension SlideShowViewController: FlickrViewModelDelegate {
    func updatePhotoIfNeeded() {
        guard let photoModel = viewModel.currentPhoto(), let urlString = photoModel.imageURL else {
            self.view.makeToast("Couldn't load photo. Thre might be some errors")
            return
        }
        
        if self.activityIndicatorView.isAnimating {
            self.activityIndicatorView.stopAnimating()
        }

        viewModel.startSlideShowIfFirstPhoto()
        showDebugIndexIfNeeded()
        animateImageView(URL(string: urlString))
    }
    
    func didFetchCompleted() {
        //will update UI if resource is updated
    }
    
    func didFetchFailed(with reason: String) {
        self.view.makeToast("didFetchFailed: \(reason)")
    }

    func didStopSlideShow() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        UIView.animate(withDuration: slideShowChangeAnimationDuration) { [weak self] in
            guard let weakSelf = self else {
                return
            }
            
            weakSelf.bottomViewHeight.constant = weakSelf.defaultBottomViewHeight
            weakSelf.slideShowSpeedButton?.isHidden = false
            weakSelf.imageViewTopConstraint.constant = weakSelf.navigationController?.navigationBar.bounds.height ?? 0.0
            weakSelf.bottomViewBottomConstraint.constant = weakSelf.view.insets.bottom
            weakSelf.previousPhotoButton.isHidden = false
            weakSelf.nextPhotoButton.isHidden = false
            weakSelf.changeSlideShowSpeed(weakSelf.viewModel.speedInSeconds)
        }
    }
    
    func willStartSlideShow() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        UIView.animate(withDuration: slideShowChangeAnimationDuration) { [weak self] in
            guard let weakSelf = self else {
                return
            }
            
            weakSelf.bottomViewHeight.constant = 0.0
            weakSelf.slideShowSpeedButton?.isHidden = true
            weakSelf.imageViewTopConstraint.constant = 0.0
            weakSelf.bottomViewBottomConstraint.constant = 0.0
            weakSelf.previousPhotoButton.isHidden = true
            weakSelf.nextPhotoButton.isHidden = true
        }
    }
    
    func willShowNextPhoto() {
        self.showNextPhoto()
    }
    
    func didChangeSlideShowSpeed(_ speed: Int) {
        self.changeSlideShowSpeed(speed)
    }
}
