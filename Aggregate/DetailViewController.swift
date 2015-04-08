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
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
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
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
    }
}
