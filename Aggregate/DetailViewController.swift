//
//  DetailViewController.swift
//  Aggregate
//
//  Created by Sophie on 4/6/15.
//  Copyright (c) 2015 Sophie. All rights reserved.
//

import UIKit
//TODO: Delete this class...?
class DetailViewController: UIViewController, UIActionSheetDelegate {

    @IBOutlet weak var imageView: UIImageView!
    var flickrPhoto : FlickrPhoto?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        flickrPhoto!.loadLargeImage { (flickrPhoto, error) -> Void in
            if (error == nil) {
                self.imageView.image = flickrPhoto.largeImage
            } else {
                self.imageView.image = flickrPhoto.thumbnail
            }
        }
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("imageTapped:"))
        imageView.userInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func imageTapped(recognizer: UITapGestureRecognizer) {
        let actionSheet: UIActionSheet = UIActionSheet(title: "Save?", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle:nil, otherButtonTitles: "Save To Camera Roll")
        actionSheet.showInView(view)
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex != actionSheet.cancelButtonIndex {
            UIImageWriteToSavedPhotosAlbum(self.imageView.image, nil, nil, nil)
        }
    }
}
