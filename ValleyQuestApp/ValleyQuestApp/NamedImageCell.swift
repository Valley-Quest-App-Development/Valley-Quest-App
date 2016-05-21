//
//  NamedImageCell.swift
//  Valley Quest App
//
//  Created by John Kotz on 5/20/16.
//  Copyright © 2016 vitalCommunities. All rights reserved.
//

import Foundation

class NamedImageCell: UITableViewCell {
    @IBOutlet weak var textInput: UITextField!
    @IBOutlet weak var namedImageView: UIImageView!
    var namedImage: UIImage!
    var delegate: ImageChooserViewController?
    var id = 0;
    
    func initialize(id: Int, image: UIImage) {
        self.id = id;
        self.setMyImage(image)
        self.selectionStyle = .None
    }
    
    func setMyImage(image: UIImage?) {
        namedImage = image
        if let namedImageView = namedImageView {
            namedImageView.image = image
        }
    }
    
    override func layoutSubviews() {
        if let namedImageView = namedImageView {
            namedImageView.image = namedImage
        }
    }
    
    @IBAction func nameChange(sender: AnyObject) {
        delegate?.nameUpdated(textInput.text, index: self.id)
    }
    
}