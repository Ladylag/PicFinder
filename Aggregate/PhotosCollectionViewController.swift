//
//  PhotosCollectionViewController.swift
//  Aggregate
//
//  Created by Sophie on 4/6/15.
//  Copyright (c) 2015 Sophie. All rights reserved.
//

import UIKit
import iAd

private let reuseIdentifier = "photoCell"

class PhotosCollectionViewController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    private var currentSearch : FlickrSearchResults?
    private var waitingForSearchAPI = false
    private let flickr = Flickr()
    
    func photoForIndexPath(indexPath: NSIndexPath) -> FlickrPhoto {
        return currentSearch!.searchResults[indexPath.row]
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        let destinationController: DetailViewController = segue.destinationViewController as! DetailViewController
        let flickrPhoto = sender as! FlickrPhoto
        destinationController.flickrPhoto = flickrPhoto
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.canDisplayBannerAds = true
    }
    
    func searchForTerm(searchTerm: String!, completion : (error : NSError?) -> Void, replaceLastResults : Bool = true) {
        self.waitingForSearchAPI = true
        var page: Int = 1
        //If we are adding more images to the search results,
        //we will need to derive which page of search results we should ask flickr for
        if (!replaceLastResults) {
            page = (self.currentSearch!.searchResults.count / numberOfResultsPerPage) + 1
        }
        flickr.searchFlickrForTerm(searchTerm, page: page) {
            results, error in
            self.waitingForSearchAPI = false
            if error != nil {
                println("Error searching : \(error)")
            }
            
            if results != nil {
                println("Found \(results!.searchResults.count) matching \(results!.searchTerm)")
                if (replaceLastResults) {
                    self.currentSearch = results!
                    self.collectionView?.reloadData()
                } else {
                    self.currentSearch?.searchResults += results!.searchResults
                    self.collectionView?.reloadData()
                }
            }
            completion(error: error)
        }
    }
    
    // MARK: UIScrollViewDelegate
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        //if the scrollview has reached the bottom and there is not currently a search in progress
        if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height) &&
            self.waitingForSearchAPI == false && self.currentSearch != nil) {
                let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
                view.addSubview(activityIndicator)
                activityIndicator.frame = view.bounds
                activityIndicator.startAnimating()
               searchForTerm(currentSearch?.searchTerm, completion: { (error) -> Void in
                    activityIndicator.removeFromSuperview()
               }, replaceLastResults: false)
        }
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView!,
        layout collectionViewLayout: UICollectionViewLayout!,
        sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
            
            let flickrPhoto =  photoForIndexPath(indexPath)
            if var size = flickrPhoto.thumbnail?.size {
                size.width += 10
                size.height += 10
                return size
            }
            return CGSize(width: 100, height: 100)
    }
    
    func collectionView(collectionView: UICollectionView!,
        layout collectionViewLayout: UICollectionViewLayout!,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    }
    
    override func collectionView(collectionView: UICollectionView,
        shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
            let flickrPhoto = photoForIndexPath(indexPath)
            self.performSegueWithIdentifier("detailViewSegue", sender: flickrPhoto)
            return true
    }
    
    // MARK: UICollectionViewDataSource
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         if currentSearch != nil {
            return currentSearch!.searchResults.count
         } else {
            return 0
        }
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PhotoCollectionViewCell
        let flickrPhoto = photoForIndexPath(indexPath)
        cell.imageView.image = flickrPhoto.thumbnail
        cell.backgroundColor = UIColor.blackColor()
        return cell
    }
    
    // MARK : UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        textField.addSubview(activityIndicator)
        activityIndicator.frame = textField.bounds
        activityIndicator.startAnimating()
        searchForTerm(textField.text, completion: { (error) -> Void in
            activityIndicator.removeFromSuperview()
            self.collectionView?.contentOffset = CGPointZero
        })
        textField.text = nil
        textField.resignFirstResponder()
        return true
    }
}
