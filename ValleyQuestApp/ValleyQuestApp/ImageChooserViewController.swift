//
//  ImageChooserViewController.swift
//  Valley Quest App
//
//  Created by John Kotz on 5/20/16.
//  Copyright © 2016 vitalCommunities. All rights reserved.
//

import Foundation
import Parse
import MobileCoreServices

class ImageChooserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var disclamerTextView: UITextView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var disclamerHeight: NSLayoutConstraint!
    
    var delegate: FeedbackViewController!
    var images: [UIImage] = []
    var files: [(String, PFFile)] = []
    let imagePicker = UIImagePickerController()
    var isChoosingPhoto = false
    
    var feedback: Feedback!
    
    override func viewDidLoad() {
        self.disclamerTextView.text = "The images you upload will be used for feedback purposes. They will also be reviewed and may be selected to be used in the Valley Quest website. If one of your photos is selected, we will contact you and ask for your permission before using it."
        self.disclamerTextView.font = UIFont.systemFontOfSize(13)
        
        images = feedback.images
        files = feedback.photos
        
        let height = HelperMethods.getHeightForText(self.disclamerTextView.text, font: UIFont.systemFontOfSize(13), width: self.disclamerTextView.frame.width, maxHeight: disclamerHeight.constant)
        disclamerHeight.constant = height
    }
    
    func addImage(image: UIImage) {
        images.append(image)
        let data = UIImagePNGRepresentation(image)!;
        let file = PFFile(data: data)!
        files.append(("", file))
        self.tableView.reloadData()
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
        isChoosingPhoto = false
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! NamedImageCell
        cell.initialize(indexPath.row, image: images[indexPath.row])
        cell.delegate = self
        
        cell.textInput.text = files[indexPath.row].0
        
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
    
    func nameUpdated(name: String?, index: Int) {
        if let name = name {
            files[index].0 = name
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.addImage(image)
        isChoosingPhoto = false
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        var actions = [UITableViewRowAction]()
        
        actions.append(UITableViewRowAction(style: .Destructive, title: "Delete", handler: { (_, indexPath) in
            self.images.removeAtIndex(indexPath.row)
            self.files.removeAtIndex(indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
        }))
        
        return actions
    }
    
    @IBAction func addPicturePressed(sender: UIButton) {
        imagePicker.allowsEditing = true;
        imagePicker.sourceType = .PhotoLibrary;
        imagePicker.delegate = self;
        imagePicker.mediaTypes = [kUTTypeImage as String]
        
        self.isChoosingPhoto = true
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        if (!isChoosingPhoto && images.count != 0) {
            feedback.addPhotos(files)
            feedback.images = images
        }
    }
    
    @IBAction func hideKeyboard(sender: AnyObject) {
        self.view.endEditing(true)
    }
}