//
//  FlickrViewModel.swift
//  FlickrDemoApp
//
//  Created by Lee Kanghee on 2019. 3. 31..
//  Copyright © 2019년 Lee Kanghee. All rights reserved.
//

import Foundation
import Kingfisher

protocol FlickrViewModelDelegate: SlideShowManagerDelegate {
    func updatePhotoIfNeeded()
    func didFetchCompleted()
    func didFetchFailed(with reason: String)
}

final class FlickrViewModel {
    //MARK: - private variables
    private let slideShowManager = SlideShowManager()
    private var photoItems: [FlickrFeedItem] = [FlickrFeedItem]()
    private var isFetchInProgress = false
    private(set) var currentItemIndex: Int = 0
    private(set) var prefetchThreshold: Int = 1
    private var requestURL: URL? {
        return URLBuilder<URL>()
            .withHost("api.flickr.com")
            .withPath("/services/feeds/photos_public.gne")
            .withParam("tags", "landscape,portrait")
            .withParam("tagmode", "any")
            .withParam("format", "json")
            .withParam("nojsoncallback", "1")
            .build()
    }
    
    //MARK: - public variables
    public weak var delegate: FlickrViewModelDelegate?
    var totalCount: Int {
        return photoItems.count
    }
    
    var speedInSeconds: Int {
        get {
            return slideShowManager.speedInSeconds
        }
        set {
            slideShowManager.speedInSeconds = newValue
        }
    }

    //MARK: - public funs
    init() {
        slideShowManager.delegate = self
    }

    func isFirstPhoto() -> Bool {
        return (currentItemIndex == 0)
    }
    
    func startSlideShowIfFirstPhoto() {
        if isFirstPhoto() {
            startSlideShow()
        }
    }

    func currentPhoto() -> FlickrFeedItem? {
        guard currentItemIndex < photoItems.count, currentItemIndex >= 0 else {
            return nil
        }
        
        return photoItems[currentItemIndex]
    }
    
    func nextPhoto() -> FlickrFeedItem? {
        if hasNextPhoto() {
            currentItemIndex = currentItemIndex + 1
            return photoItems[currentItemIndex]
        }
        return nil
    }
    
    func previousPhoto() -> FlickrFeedItem? {
        if hasPreviousPhoto() {
            currentItemIndex = currentItemIndex - 1
            return photoItems[currentItemIndex]
        }
        return nil
    }
    
    func photoItem(at index: Int) -> FlickrFeedItem {
        return photoItems[index]
    }
    
    func fetchPhotosIfNeeded() {
        if (self.photoItems.count - currentItemIndex) == prefetchThreshold {
            fetchPhotos()
        }
    }

    func fetchPhotos() {
        guard !isFetchInProgress, let url = self.requestURL else {
            return
        }
        
        isFetchInProgress = true
        
        let task = URLSession.shared.requestFlickerFeed(with: url) { [weak self] flickerFeed, response, error in
            guard let weakSelf = self else {
                return
            }
            
            guard error == nil else {
                DispatchQueue.main.async {
                    weakSelf.delegate?.didFetchFailed(with: "Network error")
                }
                return
            }
            let urls = flickerFeed?.items?.compactMap { $0.imageURL }.compactMap { URL(string: $0) }
            
            if let downloadURLS = urls {
                let prefetcher = ImagePrefetcher(urls: downloadURLS) { skippedResources, failedResources, completedResources in
                    DispatchQueue.main.async {
                        weakSelf.delegate?.updatePhotoIfNeeded()
                    }
                }
                prefetcher.start()
            }
            
            DispatchQueue.main.async {
                if let feedCount = flickerFeed?.items?.count {
                    weakSelf.prefetchThreshold = (feedCount > 0 && weakSelf.prefetchThreshold != feedCount) ? Int(feedCount / 2): weakSelf.prefetchThreshold
                }
                
                flickerFeed?.items?.forEach({ (items) in
                    weakSelf.photoItems.append(items)
                })

                weakSelf.delegate?.didFetchCompleted()
                weakSelf.isFetchInProgress = false
            }
        }
        
        task.resume()
    }
    
    func isStartedSlideShow() -> Bool {
        return self.slideShowManager.isStartedSlideShow()
    }
    
    func stopSlideShow() {
        self.slideShowManager.stopSlideShow()
    }
    
    func startSlideShow() {
        self.slideShowManager.startSlideShow()
    }
    
    func increaseSpeed() {
        self.slideShowManager.increaseSpeed()
    }
    
    func movedToNextSlide() {
        self.slideShowManager.movedToNextSlide()
    }
    
    //MARK: - private funs
    private func hasNextPhoto() -> Bool {
        guard currentItemIndex < (photoItems.count - 1), currentItemIndex >= 0 else {
            return false
        }
        return true
    }
    
    private func hasPreviousPhoto() -> Bool {
        guard (currentItemIndex - 1) >= 0, currentItemIndex >= 0 else {
            return false
        }
        return true
    }
}

extension FlickrViewModel: SlideShowManagerDelegate {
    func willShowNextPhoto() {
        self.delegate?.willShowNextPhoto()
    }
    
    func didChangeSlideShowSpeed(_ speed: Int) {
        self.delegate?.didChangeSlideShowSpeed(speed)
    }
    
    func willStartSlideShow() {
        self.delegate?.willStartSlideShow()
    }
    
    func didStopSlideShow() {
        self.delegate?.didStopSlideShow()
    }
}
